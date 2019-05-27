module Internal.AABB exposing
    ( AABB
    , convex
    , dimensions
    , extend
    , impossible
    , plane
    , sphere
    )

import Internal.Const as Const
import Internal.Convex as Convex exposing (Convex)
import Internal.Quaternion as Quaternion
import Internal.Transform as Transform exposing (Transform)
import Internal.Vector3 as Vec3 exposing (Vec3, vec3)


type alias AABB =
    { upperBound : Vec3
    , lowerBound : Vec3
    }


zero : AABB
zero =
    { lowerBound = Vec3.zero
    , upperBound = Vec3.zero
    }


maximum : AABB
maximum =
    { lowerBound = vec3 -Const.maxNumber -Const.maxNumber -Const.maxNumber
    , upperBound = vec3 Const.maxNumber Const.maxNumber Const.maxNumber
    }


impossible : AABB
impossible =
    { lowerBound = vec3 Const.maxNumber Const.maxNumber Const.maxNumber
    , upperBound = vec3 -Const.maxNumber -Const.maxNumber -Const.maxNumber
    }


extend : AABB -> AABB -> AABB
extend aabb1 aabb =
    let
        l =
            aabb.lowerBound

        u =
            aabb.upperBound

        l1 =
            aabb1.lowerBound

        u1 =
            aabb1.upperBound
    in
    { lowerBound = vec3 (min l.x l1.x) (min l.y l1.y) (min l.z l1.z)
    , upperBound = vec3 (max u.x u1.x) (max u.y u1.y) (max u.z u1.z)
    }


convex : Convex -> Transform -> AABB
convex { vertices } transform =
    List.foldl
        (\point ->
            let
                p =
                    Transform.pointToWorldFrame transform point
            in
            extend (AABB p p)
        )
        impossible
        vertices


dimensions : AABB -> Vec3
dimensions { lowerBound, upperBound } =
    Vec3.sub upperBound lowerBound


plane : Transform -> AABB
plane { position, orientation } =
    let
        { x, y, z } =
            Quaternion.rotate orientation Vec3.k
    in
    if abs x == 1 then
        { maximum | upperBound = vec3 position.x (x * Const.maxNumber) (x * Const.maxNumber) }

    else if abs y == 1 then
        { maximum | lowerBound = vec3 (y * Const.maxNumber) position.y (y * Const.maxNumber) }

    else if abs z == 1 then
        { maximum | lowerBound = vec3 (z * Const.maxNumber) (z * Const.maxNumber) position.z }

    else
        maximum


sphere : Float -> Transform -> AABB
sphere radius { position } =
    let
        c =
            position
    in
    { lowerBound = vec3 (c.x - radius) (c.y - radius) (c.z - radius)
    , upperBound = vec3 (c.x + radius) (c.y + radius) (c.z + radius)
    }
