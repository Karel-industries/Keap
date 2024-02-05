## SWP - fast local-to-local swap (swaps between two regs)
| instruction | registers |
| ---- | ---- |
| swp r0 r1 | r0 <-> r1 |
| swp r0 r2 | r0 <-> r2 |
| swp r0 r3 | r0 <-> r3 |
| swp r0 r4 | r0 <-> r4 |
| swp r1 r2 | r1 <-> r2 |
| swp r1 r3 | r1 <-> r3 |
| swp r1 r4 | r1 <-> r4 |
| swp r2 r3 | r2 <-> r3 |
| swp r2 r4 | r2 <-> r4 |
| swp r3 r4 | r3 <-> r4 |

## WLL - local to local write (copy from reg to reg2)
| instruction | registers |
| ---- | ---- |
| wll r0 r1 | r0 -> r1 |
| wll r0 r2 | r0 -> r2 |
| wll r0 r3 | r0 -> r3 |
| wll r0 r4 | r0 -> r4 |
| wll r1 r0 | r1 -> r0 |
| wll r1 r2 | r1 -> r2 |
| wll r1 r3 | r1 -> r3 |
| wll r1 r4 | r1 -> r4 |
| wll r2 r0 | r2 -> r0 |
| wll r2 r1 | r2 -> r1 |
| wll r2 r3 | r2 -> r3 |
| wll r2 r4 | r2 -> r4 |
| wll r3 r0 | r3 -> r0 |
| wll r3 r1 | r3 -> r1 |
| wll r3 r2 | r3 -> r2 |
| wll r3 r4 | r3 -> r4 |
| wll r4 r0 | r4 -> r0 |
| wll r4 r1 | r4 -> r1 |
| wll r4 r2 | r4 -> r2 |
| wll r4 r3 | r4 -> r3 |

## WLR - local to remote write (copy data from reg to ram at reg2)
| instruction | registers |
| ---- | ---- |
| wlr r0 r1 | r0 -> r1 |
| wlr r0 r2 | r0 -> r2 |
| wlr r0 r3 | r0 -> r3 |
| wlr r0 r4 | r0 -> r4 |
| wlr r1 r0 | r1 -> r0 |
| wlr r1 r2 | r1 -> r2 |
| wlr r1 r3 | r1 -> r3 |
| wlr r1 r4 | r1 -> r4 |
| wlr r2 r0 | r2 -> r0 |
| wlr r2 r1 | r2 -> r1 |
| wlr r2 r3 | r2 -> r3 |
| wlr r2 r4 | r2 -> r4 |
| wlr r3 r0 | r3 -> r0 |
| wlr r3 r1 | r3 -> r1 |
| wlr r3 r2 | r3 -> r2 |
| wlr r3 r4 | r3 -> r4 |
| wlr r4 r0 | r4 -> r0 |
| wlr r4 r1 | r4 -> r1 |
| wlr r4 r2 | r4 -> r2 |
| wlr r4 r3 | r4 -> r3 |

## WRL - remote to local write (copy data from ram at reg2 to reg)
| instruction | registers |
| ---- | ---- |
| wrl r0 r1 | r0 <- r1 |
| wrl r0 r2 | r0 <- r2 |
| wrl r0 r3 | r0 <- r3 |
| wrl r0 r4 | r0 <- r4 |
| wrl r1 r0 | r1 <- r0 |
| wrl r1 r2 | r1 <- r2 |
| wrl r1 r3 | r1 <- r3 |
| wrl r1 r4 | r1 <- r4 |
| wrl r2 r0 | r2 <- r0 |
| wrl r2 r1 | r2 <- r1 |
| wrl r2 r3 | r2 <- r3 |
| wrl r2 r4 | r2 <- r4 |
| wrl r3 r0 | r3 <- r0 |
| wrl r3 r1 | r3 <- r1 |
| wrl r3 r2 | r3 <- r2 |
| wrl r3 r4 | r3 <- r4 |
| wrl r4 r0 | r4 <- r0 |
| wrl r4 r1 | r4 <- r1 |
| wrl r4 r2 | r4 <- r2 |
| wrl r4 r3 | r4 <- r3 |

## DRL - local drain (set local register to zero)
| instruction | registers |
| ---- | ---- |
| drl r0 | r0 |
| drl r1 | r1 |
| drl r2 | r2 |
| drl r3 | r3 |
| drl r4 | r4 |

## DRR - remote drain (set remote address at reg to zero)
| instruction | registers |
| ---- | ---- |
| drr r0 | r0 |
| drr r1 | r1 |
| drr r2 | r2 |
| drr r3 | r3 |
| drr r4 | r4 |

## UADD - add unsigned value in reg2 to reg
| instruction | registers |
| ---- | ---- |
| uadd r0 r0 | r0 <- r0 |
| uadd r0 r1 | r0 <- r1 |
| uadd r0 r2 | r0 <- r2 |
| uadd r0 r3 | r0 <- r3 |
| uadd r1 r0 | r1 <- r0 |
| uadd r1 r1 | r1 <- r1 |
| uadd r1 r2 | r1 <- r2 |
| uadd r1 r3 | r1 <- r3 |
| uadd r2 r0 | r2 <- r0 |
| uadd r2 r1 | r2 <- r1 |
| uadd r2 r2 | r2 <- r2 |
| uadd r2 r3 | r2 <- r3 |
| uadd r3 r0 | r3 <- r0 |
| uadd r3 r1 | r3 <- r1 |
| uadd r3 r2 | r3 <- r2 |
| uadd r3 r3 | r3 <- r3 |

## USUB - substract unsigned value in reg2 from reg
| instruction | registers |
| ---- | ---- |
| usub r0 r1 | r0 <- r1 |
| usub r0 r2 | r0 <- r2 |
| usub r0 r3 | r0 <- r3 |
| usub r1 r0 | r1 <- r0 |
| usub r1 r2 | r1 <- r2 |
| usub r1 r3 | r1 <- r3 |
| usub r2 r0 | r2 <- r0 |
| usub r2 r1 | r2 <- r1 |
| usub r2 r3 | r2 <- r3 |
| usub r3 r0 | r3 <- r0 |
| usub r3 r1 | r3 <- r1 |
| usub r3 r2 | r3 <- r2 |

## UMUL - multiply register by register2 (TODO/RESERVED)
| instruction | registers |
| ---- | ---- |
| umul r0 r1 | r0 <- r1 |
| umul r0 r2 | r0 <- r2 |
| umul r0 r3 | r0 <- r3 |
| umul r1 r0 | r1 <- r0 |
| umul r1 r2 | r1 <- r2 |
| umul r1 r3 | r1 <- r3 |
| umul r2 r0 | r2 <- r0 |
| umul r2 r1 | r2 <- r1 |
| umul r2 r3 | r2 <- r3 |
| umul r3 r0 | r3 <- r0 |
| umul r3 r1 | r3 <- r1 |
| umul r3 r2 | r3 <- r2 |

## UDIV - divide register by register2 (TODO/RESERVED)
| instruction | registers |
| ---- | ---- |
| udiv r0 r1 | r0 <- r1 |
| udiv r0 r2 | r0 <- r2 |
| udiv r0 r3 | r0 <- r3 |
| udiv r1 r0 | r1 <- r0 |
| udiv r1 r2 | r1 <- r2 |
| udiv r1 r3 | r1 <- r3 |
| udiv r2 r0 | r2 <- r0 |
| udiv r2 r1 | r2 <- r1 |
| udiv r2 r3 | r2 <- r3 |
| udiv r3 r0 | r3 <- r0 |
| udiv r3 r1 | r3 <- r1 |
| udiv r3 r2 | r3 <- r2 |

## UINC increment register by 1
| instruction | registers |
| ---- | ---- |
| uinc r0 | r0 |
| uinc r1 | r1 |
| uinc r2 | r2 |
| uinc r3 | r3 |

## UDEC decrement register by 1
| instruction | registers |
| ---- | ---- |
| udec r0 | r0 |
| udec r1 | r1 |
| udec r2 | r2 |
| udec r3 | r3 |

