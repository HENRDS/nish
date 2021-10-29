import lexbase, strutils, ropes, sugar


const 
  InvalidChar = '\xff';
type
  NodeKind* = enum
    nkCmd, nkPipe, nkVar, nkArg
  Node* {.acyclic.} = ref object 
    kind*: NodeKind
    data*: string
    children*: seq[Node]
  
  ShellLexer* = object
    bufPos: int
    buf: string
    lexemeStart: int
    


proc initShellLexer*(): ShellLexer =
  ShellLexer(bufPos: 0, lexemeStart: 0, buf: "")

proc reset*(l: var ShellLexer, newBuf: string)=
  l.bufPos = 0
  l.lexemeStart = 0
  l.buf = newBuf

template isAtEnd(l: ShellLexer): bool = 
  l.bufPos >= l.buf.len()

template current(l: ShellLexer): char =
  if l.isAtEnd(): 
    InvalidChar
  else:
    l.buf[l.bufPos]
  
proc advance(l: var ShellLexer)=
  l.bufPos += 1

proc match(l: var ShellLexer, options: varargs[char]): bool =
  if options.contains(l.current):
    l.advance()
    return true
  return false

proc lexText(l: var ShellLexer): string =
  discard
proc nextToken(l: var ShellLexer): string =
  discard