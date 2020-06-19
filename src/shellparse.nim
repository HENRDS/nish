import lexbase, strutils, ropes, streams


type
  NodeKind* = enum
    nkCmd, nkPipe, nkVar, nkQuoted
  Node* {.acyclic.} = ref object
    case kind: NodeKind
    of nkCmd:
      cmd: string
      args: seq[Node]
    of nkPipe:
      children: seq[Node]
    of nkQuoted, nkVar:
      value: string
  CommandParser = object of BaseLexer
    parent: Node
    lexeme: string

const
  WsChars = { ' ', '\t', '\v', '\f', '\r' }

proc open(p: var CommandParser, s: Stream)=
  lexbase.open(p, s)
  p.lexeme = ""

proc atEnd(p: CommandParser): bool = p.bufpos < len(p.buf)

proc cur(p: CommandParser): char = p.buf[p.bufpos]

proc capture(p: var CommandParser, startPos, endPos: int)=
  p.lexeme = p.buf[startPos..endPos]
  p.bufpos = endPos


proc parseQuoted(p: var CommandParser)=
  let quoteChar = p.cur()
  var i = p.bufpos
  inc(i)
  while not p.atEnd() and p.buf[i] != quoteChar:
    inc(i)
  p.capture(p.bufpos+1, i-1)

proc parseComponent(p: var CommandParser)=

  var i = p.bufpos
  while not p.atEnd() and p.buf[i] notin WsChars:
    inc(i)
    p.capture(p.bufpos, i)
  if i > p.bufpos:
    return Node(kind: nkCmd, )

proc shellSplit(s: string): seq[string]=
  type State = enum sStart, sError, sQuoted
  let
    i = 0
    state = sStart
  var
    quoteChar = '\0'
  result = @[]
  while i < s.len():
    case state
    of sStart:
      case s[i]
      of '\'', '"':
        state = sQuoted
        quoteChar = s[i]
      of ' ':

    of sError:
      break



proc nextToken(p: var CommandParser): NodeKind =
  var c = p.cur()
  case c
  of '"', '\'':
    p.parseQuoted()
    result = nkQuoted
  else:
    p.parseComponent()
    result = nkCmd




proc parse(p: var CommandParser): Node =
  while not p.atEnd():
    let kind = p.nextToken()
    case kind
    of nkCmd:
      result = Node(kind: nkCmd, cmd: p.lexeme)
    of nkQuoted:





proc shellParse*(s: Stream): Node =
  var p = CommandParser()
    p.open(s)
    defer: close(p)
    p.parse()

proc shellParse*(s: string): Node =
  shellParse(newStringStream(s))

proc shellParse*(f: File): Node =
  shellParse(newFileStream(f))