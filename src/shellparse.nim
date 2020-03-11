import lexbase, strutils, ropes, sugar


type
  NodeKind = enum
    nkCmd, nkPipe, nkVar, nkQuoted
  Node {.acyclic.} = ref object 
    data: string
    children: seq[Node]
  CommandParser = object of BaseLexer
    parent: Node




proc shellSplit*(s: string): seq[string]= 
  var
    buf = ""
    inStr = false
  result = @[]
  for c in s:
    case c
    of ' ':
      if inStr:
        buf &= c
      else:
        result.add(buf)
        buf = ""
    else:
      buf &= c
  if len(result) == 0:
    result.add(s)

