open System.IO

let TEST = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"""

let tlines = TEST.Split("\n")

let lineMatches (l: string) =
    let parts = l.Split(": ")
    let numbers = 
        parts[1].Split(" | ")
        |> Array.map (fun part -> part.Split(" ", System.StringSplitOptions.RemoveEmptyEntries))
        |> Array.map (fun n -> n |> Array.map int)
    let your_n = numbers[0]
    let winning_n = numbers[1]
    let n_matches = 
        your_n
        |> Array.filter (fun n -> Array.contains n winning_n)
        |> Array.length
    n_matches

let linePoints (l: string) =
    let matches = lineMatches l
    let points = pown 2 (matches - 1)
    points

let rec recCardCount (i: int) (t: int[]): int =
    let value = t[i]
    if value = 0 then
        1 // Bottom of the tree. Count card
    else
        let search = // Count all cards beneath
            [i + 1 .. i + value]
            |> Seq.sumBy (fun ni -> recCardCount ni t)
        search + 1 // Count current card as well

type Part = One | Two

let getTotal (l: string[]) (p: Part) = 
    match p with
    | One ->
        l 
        |> Array.map linePoints 
        |> Array.sum
    | Two ->
        let matches = l |> Array.map lineMatches
        matches 
        |> Array.indexed 
        |> Array.sumBy (fun (i, _)-> recCardCount i matches)

let check (actual) (expected) =
    if expected <> actual then failwith $"expected %A{expected}, got %A{actual}" else printfn "pass"

let lines = File.ReadAllLines "2023/inputs/4.txt"

check (getTotal tlines One) 13
check (getTotal lines One) 23673
check (getTotal tlines Two) 30

let part2 = getTotal lines Two
printfn "%A" part2