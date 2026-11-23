#time "on"

open System
open System.IO

[<Literal>]
let NotFound = 0

let l3_w_val (w: ReadOnlySpan<char>) =
    if w.SequenceEqual("one".AsSpan()) then 1
    elif w.SequenceEqual("two".AsSpan()) then 2
    elif w.SequenceEqual("six".AsSpan()) then 6
    else NotFound

let l4_w_val (w: ReadOnlySpan<char>) =
    if w.SequenceEqual("four".AsSpan()) then 4
    elif w.SequenceEqual("five".AsSpan()) then 5
    elif w.SequenceEqual("nine".AsSpan()) then 9
    else NotFound

let l5_w_val (w: ReadOnlySpan<char>) =
    if w.SequenceEqual("three".AsSpan()) then 3
    elif w.SequenceEqual("seven".AsSpan()) then 7
    elif w.SequenceEqual("eight".AsSpan()) then 8
    else NotFound

/// The digit at position i, or NotFound (0)
let digitAt (s: string) (i: int) : int =
    let n = int s[i] - int '0' //Convert ASCII to INT
    if n >= 1 && n <= 9 then n else NotFound

/// The number word starting at position i, or NotFound (0)
let wordAt (s: string) (i: int) : int =
    let rest = s.AsSpan(i)
    let result = // Aggregate value over 3, 4, 5 letter words. We only expect 1 match and non-matches are 0 so addition is fine.
        (if rest.Length >= 3 then l3_w_val (rest.Slice(0, 3)) else NotFound)
        + (if rest.Length >= 4 then l4_w_val (rest.Slice(0, 4)) else NotFound)
        + (if rest.Length >= 5 then l5_w_val (rest.Slice(0, 5)) else NotFound)
    result

type Finder = string -> int -> int

let numberAt : Finder = digitAt

let fullNumberAt : Finder =
    fun s i ->
        let d = digitAt s i
        if d <> NotFound then d else wordAt s i

let getFinder (part: int) : Finder =
    match part with
    | 1 -> numberAt
    | 2 -> fullNumberAt
    | _ -> failwith "unknown part"

let lineValue (finder: Finder) (l: string) : int =
    let mutable first = NotFound
    let mutable i = 0
    while first = NotFound && i < l.Length do
        first <- finder l i
        i <- i + 1
    let mutable last = NotFound
    let mutable j = l.Length - 1
    while last = NotFound && j >= 0 do
        last <- finder l j
        j <- j - 1
    first * 10 + last // Combine numbers with arithmetic not string logic. *10 0 pads the first value.

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
