"""Read and write the addon's SavedVariables without executing Lua.

The subset is the one World of Warcraft writes: assignments, tables, strings,
numbers, booleans, and nil. It is not a Lua interpreter.
"""

from __future__ import annotations


class LuaError(ValueError):
    pass


class Table:
    def __init__(self) -> None:
        self.items: list[tuple[object, object]] = []

    def get(self, key: object) -> object:
        for existing, value in self.items:
            if existing == key:
                return value
        return None

    def set(self, key: object, value: object) -> None:
        for index, (existing, _) in enumerate(self.items):
            if existing == key:
                self.items[index] = (key, value)
                return
        self.items.append((key, value))

    def as_dict(self) -> dict[object, object]:
        return {key: value for key, value in self.items if key is not None}


class Parser:
    def __init__(self, text: str) -> None:
        self.text = text
        self.at = 0

    def parse_file(self) -> dict[str, Table]:
        tables: dict[str, Table] = {}
        self._skip()
        while self.at < len(self.text):
            name = self._ident()
            self._skip()
            self._expect("=")
            value = self._value()
            if not isinstance(value, Table):
                raise LuaError(f"{name} is not a table.")
            tables[name] = value
            self._skip()
        return tables

    def _peek(self, token: str) -> bool:
        return self.text.startswith(token, self.at)

    def _expect(self, token: str) -> None:
        if not self._peek(token):
            raise LuaError(f"Expected {token}.")
        self.at += len(token)

    def _skip(self) -> None:
        while self.at < len(self.text):
            char = self.text[self.at]
            if char in " \t\r\n":
                self.at += 1
                continue
            if self.text.startswith("--", self.at):
                self.at += 2
                while self.at < len(self.text) and self.text[self.at] != "\n":
                    self.at += 1
                continue
            break

    def _ident(self) -> str:
        start = self.at
        if start >= len(self.text) or not (self.text[start].isascii() and (self.text[start].isalpha() or self.text[start] == "_")):
            raise LuaError("Expected a name.")
        self.at += 1
        while self.at < len(self.text) and self.text[self.at].isascii() and (self.text[self.at].isalnum() or self.text[self.at] == "_"):
            self.at += 1
        return self.text[start:self.at]

    def _value(self) -> object:
        self._skip()
        if self.at >= len(self.text):
            raise LuaError("Expected a value.")
        char = self.text[self.at]
        if char == "{":
            return self._table()
        if char == '"':
            return self._string()
        if char == "-" or char.isdigit():
            return self._number()
        if self._peek("true"):
            self.at += 4
            return True
        if self._peek("false"):
            self.at += 5
            return False
        if self._peek("nil"):
            self.at += 3
            return None
        raise LuaError("Expected a value.")

    def _string(self) -> str:
        self._expect('"')
        chars: list[str] = []
        while self.at < len(self.text):
            char = self.text[self.at]
            if char == '"':
                self.at += 1
                return "".join(chars)
            if char == "\\":
                self.at += 1
                if self.at >= len(self.text):
                    raise LuaError("A string escape was cut off.")
                escaped = self.text[self.at]
                self.at += 1
                chars.append({"n": "\n", "r": "\r", "t": "\t", "\\": "\\", '"': '"', "'": "'"}.get(escaped, escaped))
                continue
            if char == "\n":
                raise LuaError("A string was broken across a line.")
            chars.append(char)
            self.at += 1
        raise LuaError("A string was not closed.")

    def _number(self) -> int | float:
        start = self.at
        if self._peek("-"):
            self.at += 1
        saw_digit = False
        while self.at < len(self.text) and (self.text[self.at].isdigit() or self.text[self.at] == "."):
            saw_digit = saw_digit or self.text[self.at].isdigit()
            self.at += 1
        if not saw_digit:
            raise LuaError("Expected a number.")
        token = self.text[start:self.at]
        return float(token) if "." in token else int(token)

    def _table(self) -> Table:
        self._expect("{")
        table = Table()
        while True:
            self._skip()
            if self._peek("}"):
                self.at += 1
                return table
            key: object = None
            if self._peek("["):
                self.at += 1
                key = self._value()
                self._skip()
                self._expect("]")
                self._skip()
                self._expect("=")
                value = self._value()
            elif self.at < len(self.text) and self.text[self.at].isascii() and (self.text[self.at].isalpha() or self.text[self.at] == "_"):
                mark = self.at
                name = self._ident()
                self._skip()
                if self._peek("="):
                    self.at += 1
                    key = name
                    value = self._value()
                else:
                    self.at = mark
                    value = self._value()
            else:
                value = self._value()
            table.items.append((key, value))
            self._skip()
            if self._peek(","):
                self.at += 1
                continue
            if self._peek("}"):
                continue
            raise LuaError("Expected the next table entry.")


def parse_saved(text: str) -> dict[str, Table]:
    return Parser(text).parse_file()


def _dump_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )
    return f'"{escaped}"'


def _dump(value: object, indent: int) -> str:
    if isinstance(value, Table):
        return _dump_table(value, indent)
    if isinstance(value, str):
        return _dump_string(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return "nil"
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, int):
        return str(value)
    raise LuaError("Cannot write this value back.")


def _dump_table(table: Table, indent: int) -> str:
    if not table.items:
        return "{}"
    pad = "\t" * indent
    inner = "\t" * (indent + 1)
    lines: list[str] = ["{"]
    for key, value in table.items:
        rendered = _dump(value, indent + 1)
        if key is None:
            lines.append(f"{inner}{rendered},")
        elif isinstance(key, str):
            lines.append(f"{inner}[{_dump_string(key)}] = {rendered},")
        else:
            lines.append(f"{inner}[{_dump(key, indent + 1)}] = {rendered},")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def dump_saved(tables: dict[str, Table]) -> str:
    parts = [f"{name} = {_dump_table(table, 0)}\n" for name, table in tables.items()]
    return "\n".join(parts)


def character_messages(character: Table) -> list[dict[str, object]]:
    raw = character.get("messages")
    if not isinstance(raw, Table):
        return []
    messages: list[dict[str, object]] = []
    for _key, value in raw.items:
        if not isinstance(value, Table):
            continue
        text = value.get("message")
        timestamp = value.get("timestamp")
        if isinstance(text, str) and isinstance(timestamp, (int, float)):
            messages.append({"message": text, "timestamp": int(timestamp)})
    return messages


def empty_messages(character: Table) -> None:
    character.set("messages", Table())
