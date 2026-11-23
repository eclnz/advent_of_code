#time "on"

open System
open System.IO

// Same approach as 2023_1.fsx, tuned to avoid allocating:
//   - finders return an int (-1 for no match) instead of a list of records
//   - words are compared in place with spans instead of slicing out substrings
//   - each line is scanned from the front for the first match and from the back for the
//     last one, stopping as soon as each is found, instead of collecting every match
//   - the two digits are combined with arithmetic instead of string concat + parse

let words = [| "zero"; "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine" |]

/// The digit at position i, or -1
let digitAt (s: string) (i: int) : int =
    let n = int s[i] - int '0'
    if n >= 0 && n <= 9 then n else -1

/// The number word starting at position i, or -1
let wordAt (s: string) (i: int) : int =
    let rest = s.AsSpan(i)
    let mutable result = -1
    let mutable w = 0
    while result < 0 && w < words.Length do
        if rest.StartsWith(words[w].AsSpan()) then result <- w
        w <- w + 1
    result

type Finder = string -> int -> int

let numberAt : Finder = digitAt

let fullNumberAt : Finder =
    fun s i ->
        let d = digitAt s i
        if d >= 0 then d else wordAt s i

let getFinder (part: int) : Finder =
    match part with
    | 1 -> numberAt
    | 2 -> fullNumberAt
    | _ -> failwith "unknown part"

let lineValue (finder: Finder) (l: string) : int =
    let mutable first = -1
    let mutable i = 0
    while first < 0 do
        first <- finder l i
        i <- i + 1
    let mutable last = -1
    let mutable j = l.Length - 1
    while last < 0 do
        last <- finder l j
        j <- j - 1
    first * 10 + last

let total (part: int) (lines: string[]) : int =
    lines |> Array.sumBy (lineValue (getFinder part))

let lines = File.ReadAllLines "2023/inputs/1_1.txt"

let main =
    let sw = System.Diagnostics.Stopwatch.StartNew()
    let part_1 = total 1 lines
    let part1Ms = sw.Elapsed.TotalMilliseconds
    sw.Restart()
    let part_2 = total 2 lines
    let part2Ms = sw.Elapsed.TotalMilliseconds
    printfn "part 1 %d. part 2 %d" part_1 part_2
    printfn "part 1 took %.2f ms, part 2 took %.2f ms (file read excluded)" part1Ms part2Ms
