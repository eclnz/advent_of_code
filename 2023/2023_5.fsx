open System.IO

let TEST = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""

// type Span =
//     { Start: int64; Length: int64}
//     member this.End = this.Start + this.Length
//     member this.Contains x = x >= this.Start && x < this.End

type Mapping = 
    {Start: int64; Destination: int64; Range: int64}
    member this.Offset = this.Destination - this.Start
    member this.Contains x = x >= this.Start && x < this.Start + this.Range
    member this.Map x = x + this.Offset
    member this.TryMap n =
        if this.Contains n then Some (this.Map n) else None 

let parseInput (s: string) =

    let sepGroups (s: string): string array =
        s.Split("\n\n")

    let sepGroupName (s: string): string * string =
        match s.Split(":") with
        | [|name; values|] -> name, values
        | other -> failwithf "expected 2 parts, got %A" other

    let parseNumbers (s: string): int64 array array =
        s.Split("\n", System.StringSplitOptions.RemoveEmptyEntries)
        |> Array.map (fun line ->
            line.Split(" ", System.StringSplitOptions.RemoveEmptyEntries)
            |> Array.map int64)
            
    let parseMap (m: int64 array) =
        match m with
        | [|dn; sn; range|] -> { Start = sn; Destination = dn; Range = range}
        | other -> failwithf "expected 2 parts, got %A" other
        
    let parseMapCollection (mc: int64 array array): Mapping array =
        mc |> Array.map parseMap
    
    let name_value_pair = sepGroups s |> Array.map sepGroupName
    let numbers = name_value_pair |> Array.map (fun (_,nums) -> parseNumbers nums)
    let seeds = numbers[0].[0]
    let maps = numbers[1..] |> Array.map parseMapCollection
    seeds, maps
    
let mapInputs (nums: int64[]) (maps: Mapping[]): int64[] = 
    nums
    |> Array.map (fun n -> 
        maps 
        |> Array.tryPick (fun map -> map.TryMap n) 
        |> Option.defaultValue n)

let transformMin (nums: int64[]) (maps_arr: Mapping array array) =
    Array.fold mapInputs nums maps_arr
    |> Array.min

let check (actual) (expected) =
    if expected <> actual then failwith $"expected %A{expected}, got %A{actual}" else printfn "pass"

let tseeds, tmaps = parseInput TEST

check (transformMin tseeds tmaps) 35

let lines = File.ReadAllText "2023/inputs/5.txt"
let seeds, maps = parseInput lines
printfn "%A" (transformMin seeds maps)