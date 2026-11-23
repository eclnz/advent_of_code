open System.IO

let TEST = """467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""

let charIsSymbol (c: char): bool =
    (System.Char.IsSymbol c || System.Char.IsPunctuation c) && c <> '.'

let charIsDigit (c: char): bool =
    System.Char.IsDigit c

let getNeighbours (w: int) (h: int) (li: int) : int list =
    let x, y = li % w, li / w
    let offsets = [-1; 0; 1]
    List.allPairs offsets offsets
    |> List.filter ((<>) (0, 0))
    |> List.choose (fun (dx, dy) ->
        let nx, ny = x + dx, y + dy
        if nx >= 0 && nx < w && ny >= 0 && ny < h
        then Some (ny * w + nx)
        else None)

let tlines = TEST.Split("\n")

let areProximals (i: int) (s: string) (w: int) (h: int) (isSymbol: char -> bool) =
    getNeighbours w h i
    |> List.exists (fun n -> isSymbol s[n])

let getProximals (i: int) (s: string) (w: int) (h: int) (isSymbol: char -> bool) =
    getNeighbours w h i
    |> List.filter (fun n -> isSymbol s[n])

let seek (i: int) (s: string) (stop: char -> bool) (step: int) =
    let mutable j = i
    while j + step < s.Length && j + step >= 0 && not (stop s[j + step]) do
        j <- j + step
    j

let seekForward (i: int) (s: string) (stop: char -> bool) =
    seek i s stop 1

let seekBackward (i: int) (s: string) (stop: char -> bool) =
    seek i s stop (-1)

let numberStartFinish (i: int) (s: string) =
    let start = seekBackward i s (charIsDigit >> not)
    let finish = seekForward i s (charIsDigit >> not)
    (start, finish)

let getPartNumbers (s: string[]) =
    let w = s[0].Length
    let h = s.Length
    let joined = String.concat "" s
    let proximals = 
        joined
        |> Seq.indexed
        |> Seq.filter (fun (i, c) -> charIsDigit c)
        |> Seq.filter (fun (i, c) -> areProximals i joined w h charIsSymbol)
    let numbers = 
        proximals
        |> Seq.map (fun (i, c) -> numberStartFinish i joined)
        |> Seq.distinct
        |> Seq.map (fun (s, f) -> joined[s .. f] |> int)
    numbers |> Seq.sum

let getGearNumbers (s: string[]) =
    let w = s[0].Length
    let h = s.Length
    let joined = String.concat "" s
    let proximals = 
        joined
        |> Seq.indexed
        |> Seq.filter (fun (i, c) -> c = '*')
        |> Seq.map (fun (i, c) -> 
            getProximals i joined w h charIsDigit
            |> Seq.map (fun i -> numberStartFinish i joined)
            |> Seq.distinct
            |> Seq.map (fun (s, f) -> joined[s .. f] |> int))
    proximals
    |> Seq.filter (fun spans -> Seq.length spans = 2)
    |> Seq.map (fun nums -> Seq.reduce (*) nums)
    |> Seq.sum

let check (actual) (expected) =
    if expected <> actual then failwith $"expected %A{expected}, got %A{actual}" else printfn "pass"

let lines = File.ReadAllLines "2023/inputs/3.txt"

check (getPartNumbers tlines) 4361
check (getPartNumbers lines) 539433
check (getGearNumbers tlines) 467835

printfn "%A" (getGearNumbers lines)