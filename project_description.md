# Opis projektu / zgłoszenie zmiany

Ten plik to punkt wejścia dla nowych zadań: opisz tu, językiem biznesowym, co chcesz żeby
powstało lub się zmieniło. Nie musisz pisać w kategoriach technicznych/architektonicznych —
zgodnie z zasadą "Plan first, code second" z `CLAUDE.md` (sekcja "Working agreement with
Claude"), Claude zamienia taki opis w plan implementacji i przedstawia go do akceptacji, zanim
zacznie pisać kod.

Jeśli czegoś tu zabraknie albo coś będzie niejednoznaczne, Claude zapyta zamiast zgadywać
(zasada "Never improvise on missing knowledge" z `CLAUDE.md`) — nie trzeba więc doprecyzowywać
wszystkiego na zapas. Im więcej pól poniżej jest wypełnionych, tym mniej pytań będzie na starcie,
ale żadne pole nie jest obowiązkowe.

---

## Szablon zgłoszenia

Skopiuj tę sekcję do "Aktualne zgłoszenie" poniżej i uzupełnij dla każdego nowego zadania.

### Tytuł

Jedno zdanie streszczające zgłoszenie (posłuży też jako punkt wyjścia do nazwy gałęzi/PR-a).

### Kontekst biznesowy

- **Co** ma się wydarzyć — funkcja, poprawka albo zmiana zachowania, opisana z punktu widzenia
  użytkownika/biznesu, nie implementacji.
  _Przykład: "Gracz, który zbierze 100 punktów w grze, ma dostać rangę VIP widoczną też poza
  grą."_
- **Po co** — jaki problem to rozwiązuje albo jaką potrzebę zaspokaja, i dla kogo (gracze?
  administratorzy gry? wy jako zespół operacyjny?).
- **Jak wygląda sukces** — po czym poznamy, że jest zrobione.
  _Przykład: "Administrator widzi status VIP w naszym dashboardzie w ciągu kilku sekund od
  zdarzenia w grze."_

### Obszar zmiany

Zaznacz, co pasuje — pomaga to od razu wiedzieć, w której warstwie/kontekście to wyląduje:

- [ ] Komunikacja wychodząca do Roblox (Open Cloud API — dane użytkownika, publikacja miejsca, ...)
- [ ] Komunikacja przychodząca z Roblox (webhook wysyłany ze skryptu w grze)
- [ ] Publikacja gry (pipeline `game/` → Roblox przez Open Cloud)
- [ ] Skrypt w grze (`game/src/**`)
- [ ] Coś nowego / inny obszar — opisz krótko czego dotyczy

### Szczegóły techniczne (jeśli już wiadomo — nieobowiązkowe)

- Konkretne dane wejściowe/wyjściowe: jakie pola, z jakiego zdarzenia w grze, do/z jakiego
  endpointu Open Cloud.
- Istniejące elementy do zmiany lub rozbudowy, jeśli już wiadomo które (np. konkretny use case,
  router, adapter).
- Czy potrzebne są nowe uprawnienia/sekrety (np. dodatkowy scope na kluczu Open Cloud), których
  jeszcze nie ma w `.env` / GitHub Secrets.

### Ograniczenia

- Terminy, jeśli są.
- Rzeczy, których nie wolno zepsuć (np. istniejące endpointy, kompatybilność z czymś innym).
- Konieczność integracji z czymś konkretnym poza tym repo.

### Priorytet

Pilne / normalne / można poczekać — i krótko dlaczego.

### Poza zakresem

Co świadomie **nie** wchodzi w to zgłoszenie, żeby zakres nie rozjechał się bez pytania.

### Otwarte pytania

Rzeczy, co do których sami nie macie jeszcze pewności. Claude i tak zapyta o niejasności, ale
warto od razu spisać to, co już wiadomo że wymaga ustalenia.

---

## Aktualne zgłoszenie

_(wklej szablon powyżej i uzupełnij dla następnego zadania)_
