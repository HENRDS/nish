
import os, osproc, strutils, strtabs, terminal, streams, linenoise
from posix import getlogin, gethostname
from shellparse import shellSplit

type 
  NiShell = object
    env: StringTableRef
    lastExitCode: int


proc getHostname(): string =
  const HostnameMaxLength = 255
  var cs = cast[cstring](alloc0(HostnameMaxLength * sizeof(char)))
  let ecode = gethostname(cs, HostnameMaxLength)
  if ecode != 0:
    result = ""
  else:
    result = $cs

proc writePrompt(s: var NiShell) =
  if s.lastExitCode != 0:
    stdout.styledWrite(fgRed, styleBright, "[", $s.lastExitCode, "]", resetStyle)
  stdout.styledWrite(fgBlue, $getlogin(), "@", getHostname(), resetStyle)
  stdout.styledWrite(":", fgCyan, getCurrentDir(), "> ", resetStyle)

proc resolvePath(s: var NiShell, cmd: string): string =
  let paths = s.env["PATH"].split({':'})
  for p in paths:
    for k, f in walkDir(p, relative = true):
      if k < pcDir and f == cmd:
        return joinPath(p, cmd)
  return cmd

proc initNiShell(): NiShell =
  result = NiShell(env: newStringTable(), lastExitCode: 0)
  result.env["PATH"] = getEnv("PATH", "/usr/local/bin:/usr/bin:/bin")



proc parseCmd(s: var NiShell, line: string): (string, seq[string]) =
  let parts = line.shellSplit()
  result = (parts[0], parts[1..parts.high])


proc writeError(msg: string) =
  stdout.styledWrite(fgRed, msg, resetStyle)

proc main(s: var NiShell) =
  while true:
    writePrompt(s)
    let line = linenoise.readLine("").string.strip()

    if line == "":
      s.lastExitCode = 0
      continue
    var (cmd, args) = parseCmd(s, line)
    if '/' notin cmd:
      cmd = resolvePath(s, cmd)
    case cmd
    of "cd":
      if len(args) > 1:
        writeError("Too many args for cd")
      else:
        setCurrentDir(args[0])
    else:
      var p = startProcess(cmd, args = args)
      defer: p.close()
      stdout.write(p.outputStream().readAll())
      s.lastExitCode = p.peekExitCode()

proc main() =
  var shell = initNiShell()
  shell.main()

when isMainModule:
  main()
