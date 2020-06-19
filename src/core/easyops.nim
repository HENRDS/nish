


template orderingByMember(t: typedesc, member: untyped): untyped =
  proc `<`*(l, r: t): bool {.inject.} = l.member < r.member
  proc `<=`*(l, r: t): bool {.inject.} = not (r > l)
  proc `>`*(l, r: t): bool {.inject.} = r < l
  proc `>=`*(l, r: t): bool {.inject.} = not (l < r)

template orderingByMemberNoExport(t: typedesc, member: untyped): untyped =
  proc `<`(l, r: t): bool {.inject.} = l.member < r.member
  proc `<=`(l, r: t): bool {.inject.} = not (r > l)
  proc `>`(l, r: t): bool {.inject.} = r < l
  proc `>=`(l, r: t): bool {.inject.} = not (l < r)


template additionByMember(t: typedesc, member: untyped): untyped =
  proc `+`(l, r: t): bool {.inject.} = l.member + r.member
  proc `-`(l, r: t): bool {.inject.} = l.member - r.member

template multiplicationByMember(t: typedesc, member: untyped): untyped =
  proc `*`(l, r: t): bool {.inject.} = l.member * r.member
  proc `/`(l, r: t): bool {.inject.} = l.member / r.member

template equalityByMember(t: typedesc, member: untyped): untyped =
  proc `==`(l, r: t): bool {.inject.} = l.member == r.member
  proc `!=`(l, r: t): bool {.inject.} = l.member != r.member

