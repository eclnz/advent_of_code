open System.IO

let reqNum (c: char) =
    match c with
    | 'r' -> 12
    | 'g' -> 13
    | 'b' -> 14
    | _ -> failwith "unknown colour"

let COLOURS = [|"red"; "green"; "blue"|]

type Pull = { Count: int; Colour: string }

let parsePull (p: string): Pull =
    match p.Split(" ") with
    | [|count; colour |] -> {Count = int count; Colour = colour}
    | _ -> failwith $"bad pull: {p}"
    

let isPossiblePull (p: string) =
    let pull = parsePull p
    let max_pos = reqNum pull.Colour.[0]
    if pull.Count <= max_pos then true else false

let formatSet (s: string) =
    s.Split(", ")

let isPossibleSet (s: string) =
    formatSet s |> Array.forall isPossiblePull

type SetTotal = { R: int; G: int; B: int }

let parseSet (s: string) : SetTotal =
    let pulls = formatSet s |> Array.map parsePull
    let countOf colour =
        pulls
        |> Array.filter (fun p -> p.Colour = colour)
        |> Array.sumBy (fun p -> p.Count)
    { R = countOf "red"; G = countOf "green"; B = countOf "blue" }

let getGameNum (s: string) =
    s.Split(" ").[1]

type GameLine = { Game: int; Sets: string[] }

let formatLine (l: string) =
    let parts = l.Split(": ")
    let sets = parts[1].Split("; ")
    let game = parts[0].Split(" ").[1] |> int
    { Game = game; Sets = sets }

let smallestSetReq (l: string): SetTotal =
    let line = formatLine l
    line.Sets 
    |> Array.map parseSet 
    |> Array.reduce (fun a s -> { R = max a.R s.R; G = max a.G s.G; B = max a.B s.B })

let cubicTotal (l: string) =
    let smallest = smallestSetReq l
    smallest.R * smallest.G * smallest.B


let possibleId (l: string): int =
    let f_line = formatLine l
    let possible = f_line.Sets |> Array.forall isPossibleSet
    if possible then f_line.Game else 0

type Part = One | Two

let total (part: Part) (lines: string[]) : int =
    match part with
    | One -> lines |> Array.sumBy possibleId
    | Two -> lines |> Array.sumBy cubicTotal

let lines = File.ReadAllLines "2023/inputs/2.txt"

let TEST = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
CustomGame 6: 12 red, 13 green, 14 blue"""

let check (actual) (expected) =
    if expected <> actual then failwith $"expected %A{expected}, got %A{actual}" else printfn "pass"

let test1 =
    let tlines = TEST.Split("\n")
    check (possibleId tlines[0]) 1
    check (possibleId tlines[1]) 2
    check (possibleId tlines[2]) 0
    check (possibleId tlines[3]) 0
    check (possibleId tlines[4]) 5
    check (possibleId tlines[4]) 5
    check (total One tlines[0 .. 4]) 8

    check (cubicTotal tlines[0]) 48
    check (cubicTotal tlines[1]) 12
    check (cubicTotal tlines[2]) 1560
    check (cubicTotal tlines[3]) 630
    check (cubicTotal tlines[4]) 36
    check (total Two tlines[0 .. 4]) 2286

let main = 
    let part_1 = total One lines
    let part_2 = total Two lines
    printfn "part 1 %d. part 2 %d" part_1 part_2
