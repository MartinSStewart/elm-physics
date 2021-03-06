module Shapes.Sphere exposing
    ( Sphere
    , atOrigin
    , expandBoundingSphereRadius
    , placeIn
    , placeInWithInertia
    , raycast
    )

import Internal.Matrix3 exposing (Mat3)
import Internal.Transform3d as Transform3d exposing (Transform3d)
import Internal.Vector3 as Vec3 exposing (Vec3)


type alias Sphere =
    { radius : Float
    , position : Vec3
    , volume : Float
    , inertia : Mat3
    }


atOrigin : Float -> Sphere
atOrigin radius =
    let
        volume =
            4 / 3 * pi * (radius ^ 3)

        i =
            2 / 5 * volume * radius * radius

        inertia =
            { m11 = i
            , m21 = 0
            , m31 = 0
            , m12 = 0
            , m22 = i
            , m32 = 0
            , m13 = 0
            , m23 = 0
            , m33 = i
            }
    in
    { radius = radius
    , position = Vec3.zero
    , volume = volume
    , inertia = inertia
    }


placeIn : Transform3d coordinates defines -> Sphere -> Sphere
placeIn transform3d { radius, position, volume, inertia } =
    { radius = radius
    , volume = volume
    , inertia = inertia -- doesn’t need to be rotated for a sphere
    , position = Transform3d.pointPlaceIn transform3d position
    }


placeInWithInertia : Transform3d coordinates defines -> Sphere -> Sphere
placeInWithInertia transform3d { radius, position, volume, inertia } =
    { radius = radius
    , volume = volume
    , inertia = Transform3d.inertiaPlaceIn transform3d position volume inertia
    , position = Transform3d.pointPlaceIn transform3d position
    }


expandBoundingSphereRadius : Sphere -> Float -> Float
expandBoundingSphereRadius { radius, position } boundingSphereRadius =
    max (Vec3.length position + radius) boundingSphereRadius


raycast : { from : Vec3, direction : Vec3 } -> Sphere -> Maybe { distance : Float, point : Vec3, normal : Vec3 }
raycast { from, direction } { position, radius } =
    let
        a =
            direction.x * direction.x + direction.y * direction.y + direction.z * direction.z

        b =
            2 * (direction.x * (from.x - position.x) + direction.y * (from.y - position.y) + direction.z * (from.z - position.z))

        c =
            (from.x - position.x) * (from.x - position.x) + (from.y - position.y) * (from.y - position.y) + (from.z - position.z) * (from.z - position.z) - radius * radius

        delta =
            b * b - 4 * a * c
    in
    if delta < 0 then
        Nothing

    else
        let
            distance =
                (-b - sqrt delta) / (2 * a)
        in
        if distance >= 0 then
            let
                point =
                    { x = from.x + direction.x * distance
                    , y = from.y + direction.y * distance
                    , z = from.z + direction.z * distance
                    }

                normal =
                    Vec3.sub point position
            in
            Just
                { distance = distance
                , point = point
                , normal = normal
                }

        else
            Nothing
