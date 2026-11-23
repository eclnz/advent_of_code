#time "on"

let charIsNum (c: char) =
    match int c - int '0' with
    | n when n >= 0 && n <=9 -> Some n
    | _ -> None

let wordIsNum (w: string) =
    match w with
    | "one" -> Some 1
    | "two" -> Some 2
    | "three" -> Some 3
    | "four" -> Some 4
    | "five" -> Some 5
    | "six" -> Some 6
    | "seven" -> Some 7
    | "eight" -> Some 8
    | "nine" -> Some 9
    | _ -> None

type WordMatch = { Position: int; Number: int }

type Finder = string -> int -> WordMatch list

//Finder
let numberAt (s: string) (i: int) : WordMatch list =
    charIsNum s[i]
    |> Option.map (fun d -> {Position = i; Number = d})
    |> Option.toList

//Finder
let fullNumberAt (s: string) (i: int) : WordMatch list =
    match charIsNum s[i] with
    | Some d -> [ { Position = i; Number = d } ]
    | None ->
        [3 .. 5]
        |> List.choose (fun n ->
            s[i .. i + n - 1]
            |> wordIsNum
            |> Option.map (fun num -> { Position = i; Number = num }))

let getFinder (part: int): Finder =
    match part with
        | 1 -> numberAt
        | 2 -> fullNumberAt
        | _ -> failwith "unknown part"

let findWordMatch (finder: Finder)(l: string): WordMatch list =
    [0 .. l.Length - 1]
    |> List.collect (finder l)

let filterWordMatch (m: WordMatch list): WordMatch * WordMatch =
    let first = m |> List.minBy (fun m -> m.Position)
    let last = m |> List.maxBy (fun m -> m.Position)
    (first, last)


let addLine (l: string) (part: int): int =
    let finder = getFinder part
    l
    |> findWordMatch finder
    |> filterWordMatch
    |> fun (a, b) -> string a.Number + string b.Number
    |> int

let part1_total (lines: string[] ) =
    lines
    |> Array.map (fun l -> addLine l 1)
    |> Array.sum

let part2_total (lines: string[] ) =
    lines
    |> Array.map (fun l -> addLine l 2)
    |> Array.sum

open System.IO

let lines = File.ReadAllLines "2023/inputs/1_1.txt"

let main =
    let sw = System.Diagnostics.Stopwatch.StartNew()
    let part_1 = part1_total lines
    let part1Ms = sw.Elapsed.TotalMilliseconds
    sw.Restart()
    let part_2 = part2_total lines
    let part2Ms = sw.Elapsed.TotalMilliseconds
    printfn "part 1 %A. part 2 %A" (part_1) (part_2)
    printfn "part 1 took %.2f ms, part 2 took %.2f ms (file read excluded)" part1Ms part2Ms
