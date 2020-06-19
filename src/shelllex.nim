import lexbase, streams, strutils, tables
include core/easyops



type TokenKind = enum
  tkWord, tkQuoted, tkInterpolatedQuote,
  tkPipe, tkSemicolon,
  tkComment

const
  StrToken = {tkWord, tkQuoted, tkComment}
  SeqToken = {tkInterpolatedQuote}
  UnvaluedToken = {tkPipe..tkSemicolon}
type
  TokenPosition* = tuple
    line, column: int
  Token* = ref object
    position*: TokenPosition
    case kind: TokenKind
    of StrToken:
      sVal: string
    of SeqToken:
      lVal: seq[Token]
    else:
      discard
  ShellLexer = object of BaseLexer



proc here(L: ShellLexer): TokenPosition = (L.lineNumber, L.getColNumber(L.bufpos))
template at(L: var ShellLexer, i: int): char = L.buf[i]

proc emitToken(L: var ShellLexer, i: int, k: TokenKind): Token =
  case k
  of UnvaluedToken:
    Token(kind: k, position: L.here())
  else:
    raise newException(Exception, "Invalid kind " & $k & ", this kind of token has a value")

template impEmitToken(t: typedesc, kinds: set[TokenKind], member: untyped): untyped =
  proc emitToken(L: var ShellLexer, i: int, k: TokenKind, v: t): Token {.inject.} =
    case k
    of kinds:
      Token(kind: k, position: L.here(), member: v)
    else:
      raise newException(Exception, "Invalid kind " & $k & " for type " & $t)

string.impEmitToken(StrToken, sVal)
seq[Token].impEmitToken(SeqToken, lVal)


proc parseQuoted(L: var ShellLexer): Token =
  var i = L.bufpos
  inc(i)
  while L.at(i) != EndOfFile:
    case L.at(i)
    of '\\':
      inc(i)
    of '\'':
      inc(i)
      break
    else:
      discard
    inc(i)

proc parseWord(L: var ShellLexer): Token =
  var i = L.bufpos
  while L.buf[i] notin Whitespace:
    inc(i)


proc nextToken(L: var ShellLexer): Token =
  let c = L.at(L.bufpos)
  case c
  of '\'':
    L.parseQuoted()
  else:
    L.parseWord()


