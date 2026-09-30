-- HybridScroll.xml references HybridScrollMixin before ArenaTable may run
-- (or when ArenaAnalytics is skipped). Keep a harmless stub available.
if not HybridScrollMixin then
  HybridScrollMixin = {}
end
