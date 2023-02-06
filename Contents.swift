/*
 * Computation of airport distances and spherical overage of triangles based
 * on a sphere earth model (not WGS84) for comparison to a flat earth model.
 *
 * As this file is basically just math, the author hereby places it into the
 * public domain for any use whatsoever and without warrantee of any kind.
 */

import CoreGraphics // brings in the math functions along with CGFloat type

// Looked up distances for mean radius of the earth
let meanEarthRadius:CGFloat = 3959.0 // miles
// let meanEarthRadius:CGFloat = 6371.0 // kilometers

struct Coordinates {
    let lat:CGFloat
    let long:CGFloat

    // convert degrees to radians
    init(lat:CGFloat, long:CGFloat) {
        self.lat = lat * CGFloat(.pi / 180.0)
        self.long = long * CGFloat(.pi / 180.0)
    }
}

/*
 * Haversine formula for calculating the great arc distance between two points on a sphere
 * https://en.wikipedia.org/wiki/Great-circle_distance
 */

func distance(_ p:Coordinates, _ q:Coordinates) -> CGFloat {
    // haversine function
    func hav(_ x:CGFloat) -> CGFloat {
        let s = sin(x/2.0)
        return s*s
    }
    
    return meanEarthRadius * 2.0 * asin(sqrt(hav(abs(p.lat - q.lat)) + cos(p.lat) * cos(q.lat) * hav(abs(p.long - q.long))))
}

/*
 * Compute angles of triangle on a sphere given the lengths of the sides using
 * the spherical law of cosines. Compute angles of a triangle on a plane using
 * law of cosines. Lengths need to be in the correct order for sensible result.
 * https://en.wikipedia.org/wiki/Solution_of_triangles
 */

func sphericalAngles(_ A:CGFloat, _ B:CGFloat, _ C:CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    let cosa = cos(A / meanEarthRadius)
    let cosb = cos(B / meanEarthRadius)
    let cosc = cos(C / meanEarthRadius)
    let sina = sin(A / meanEarthRadius)
    let sinb = sin(B / meanEarthRadius)
    let sinc = sin(C / meanEarthRadius)
    let toDeg = CGFloat(180.0 / .pi)
    let a = acos((cosa - cosb * cosc) / (sinb * sinc)) * toDeg
    let b = acos((cosb - cosa * cosc) / (sina * sinc)) * toDeg
    let c = acos((cosc - cosa * cosb) / (sina * sinb)) * toDeg

    return (a,b,c, a+b+c)
}

func planeAngles(_ A:CGFloat, _ B:CGFloat, _ C:CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    let toDeg = CGFloat(180.0 / .pi)
    let a = acos((B*B + C*C - A*A) / (2.0 * B * C)) * toDeg
    let b = acos((A*A + C*C - B*B) / (2.0 * A * C)) * toDeg
    let c = acos((A*A + B*B - C*C) / (2.0 * A * B)) * toDeg

    return (a, b, c, a+b+c)
}

/*
 * Airport coordinates come from WolframAlpha.
 */

let HND = Coordinates(lat: 35.55, long: 139.8)   // Tokyo International Airport
let JFK = Coordinates(lat: 40.64, long: -73.78)  // New York JFK Airport
let LHR = Coordinates(lat: 51.48, long: -0.4614) // London Heathrow Airport
let SFO = Coordinates(lat: 37.62, long: -122.4)  // Sanfransisco International Airport
let SYD = Coordinates(lat: -33.95, long: 151.2)  // Sydney International Airport

/*
 * Compute distances from each airport to each other airport
 */

let HNDtoJFK = distance(HND, JFK)
let HNDtoLHR = distance(HND, LHR)
let HNDtoSFO = distance(HND, SFO)
let HNDtoSYD = distance(HND, SYD)

let JFKtoLHR = distance(JFK, LHR)
let JFKtoSFO = distance(JFK, SFO)
let JFKtoSYD = distance(JFK, SYD)

let LHRtoSFO = distance(LHR, SFO)
let LHRtoSYD = distance(LHR, SYD)

let SFOtoSYD = distance(SFO, SYD)

planeAngles(1.0, 1.0, 1.0) // This is a sanity check.
planeAngles(HNDtoSFO, SFOtoSYD, HNDtoSYD)
planeAngles(JFKtoSFO, LHRtoSFO, JFKtoLHR)

sphericalAngles(1.0, 1.0, 1.0) // This is also a sanity check.
sphericalAngles(HNDtoSFO, SFOtoSYD, HNDtoSYD)
sphericalAngles(JFKtoSFO, LHRtoSFO, JFKtoLHR)

// And yet another sanity check on the math.
let quarterCircle = meanEarthRadius * CGFloat(.pi / 2.0)
sphericalAngles(quarterCircle, quarterCircle, quarterCircle)

/*
 * More sanity checking.
 */

let northPole = Coordinates(lat: 90.0, long: 0.0)
let PER = Coordinates(lat: -31.96, long: 115.8)
let PERtoSYD = distance(PER, SYD)
let northPoleToPER = distance(northPole, PER)
let northPoleToSYD = distance(northPole, SYD)
planeAngles(PERtoSYD, northPoleToSYD, northPoleToPER)
sphericalAngles(PERtoSYD, northPoleToSYD, northPoleToPER)
