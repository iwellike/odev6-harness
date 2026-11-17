# Gerçek Claude Code ölçümü (claude -p --output-format json)

| Tur | num_turns | input | cache_read | cache_creation | output | total_cost_usd | is_error |
|---|---:|---:|---:|---:|---:|---:|---|
| A1 | 2 | 4 | 20984 | 45655 | 229 | 0.28367220000000004 | false |
| A2 | 3 | 6 | 103032 | 8477 | 2265 | 0.1157646 | false |
| A3 | 9 | 18 | 404854 | 16875 | 6422 | 0.3190902 | false |
| A4 | 9 | 18 | 479886 | 34812 | 7801 | 0.4699067999999999 | false |
| B | 11 | 14 | 254907 | 37577 | 3442 | 0.3536061 | false |
| **A toplam** | 23 | 46 | 1008756 | 105819 | 16717 | 1.188434 | |

## A toplam ile B farkı

- num_turns: A toplam=23, B=11, fark=12.0 (A'ya göre %52.2)
- input: A toplam=46, B=14, fark=32.0 (A'ya göre %69.6)
- cache_read: A toplam=1008756, B=254907, fark=753849.0 (A'ya göre %74.7)
- output: A toplam=16717, B=3442, fark=13275.0 (A'ya göre %79.4)
- total_cost_usd: A toplam=1.188434, B=0.3536061, fark=0.834828 (A'ya göre %70.2)

> Not: total_cost_usd, Claude Pro abonelik üzerinden çalıştırıldığında API karşılığı maliyet TAHMİNİDİR (gerçek Pro faturasına ek ücret yansımaz).

## Otomatik kanca çalışması

B koşusunda, tek insan turu içinde `bin/kontrol` kancası **3** kez otomatik çalıştı (kaynak: `kanit/claude_p/B/kontrol.log`).

---
**Sonradan eklenen not:** "3 kez otomatik" sayısı `kontrol.log` satır sayısıdır. Bu sürümdeki `bin/kontrol` çalıştıranı (kanca / elle) günlüğe yazmadığı için kaçının kanca olduğu kesin değildir; bkz. README "Gerçek Claude Code ölçümü".
