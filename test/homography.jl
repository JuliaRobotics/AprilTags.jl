struct PixPos
     pix::UInt8
     pos::NamedTuple{(:x, :y, :z),Tuple{Float64, Float64, Float64}}
end
PixPos(pix::UInt8, pos::Vector{Float64}) = PixPos(pix, (x=pos[1], y=pos[2], z=pos[3]))
PixPos(pix::UInt8, pos::Array{Float64,1}) = PixPos(pix, (x=pos[1], y=pos[2], z=pos[3]))

@testset "Homography to Pose" begin

    fx = 1000.
    fy = 1000.
    cx = 320.
    cy = 240.

    K = [fx 0  cx;
          0 fy cy]

    C = [K; 0 0 1]

    detector = AprilTagDetector()

    #_____________________________________________________________________


    #test offset only
    test_cTw = [[1.0  0.0  0.0  -100.0;
                 0.0  1.0  0.0  -100.0;
                 0.0  0.0  1.0  1500.0;
                 0.0  0.0  0.0     1.0]]

    #test offset only
    #FIXME bigger offsets like this one fails test
    #=
    push!(test_cTw, [1.0  0.0  0.0   320.0;
                     0.0  1.0  0.0  -200.0;
                     0.0  0.0  1.0  1500.0;
                     0.0  0.0  0.0     1.0])
    =#

    #test horizontal angle
    push!(test_cTw, [ 0.707107  0.0  0.707107  0.0;
                      0.0       1.0  0.0       0.0;
                     -0.707107  0.0  0.707107  1500.0;
                      0.0       0.0  0.0       1.0])

    #test offset and horizontal angle
    push!(test_cTw, [ 0.707107  0.0  0.707107  100.0;
                      0.0       1.0  0.0       100.0;
                     -0.707107  0.0  0.707107  1000.0;
                      0.0       0.0  0.0       1.0])

    #test vertical angle
    push!(test_cTw, [ 1.0  0.0       0.0       0.0;
                      0.0  0.707107  0.707107  0.0;
                      0.0 -0.707107  0.707107  1500.0;
                      0.0  0.0       0.0       1.0])

    #test 2 angles
    push!(test_cTw, [0.707107   0.0       -0.707107     0.0;
                     0.5        0.707107   0.5        -60.6602;
                     0.5       -0.707107   0.5       2060.66;
                     0.0        0.0        0.0          1.0])

    for cTw = test_cTw
        back = ones(UInt8, 301,301)*0x40
        back[11:290,11:290] =  ones(UInt8, 280,280)*0x80

        #tag 0 draw in camera frame
        #_____________________________________________________________________
        tag0 = kron(reinterpret(UInt8,getAprilTagImage(0)), ones(UInt8, 20,20))
        back[51:250,51:250] = tag0'

        x = collect(-150.:150)
        y = collect(-150.:150)
        z = 0.

        tag0cloud = Array{PixPos,2}(undef, 301,301)
        for i = 1:301, j = 1:301
           tag0cloud[i,j] = PixPos(back[i,j],[x[i]; y[j]; z])
        end

        #Projection
        #_____________________________________________________________________

        projImg = zeros(Float32, 480,640);
        cnt = zeros(Int, 480,640);

        for i = 1:301, j = 1:301
            tc = tag0cloud[i,j]
            pos = C*cTw[1:3,1:4]*[tc.pos.x; tc.pos.y; tc.pos.z; 1]
            pos /= pos[3]
            u = round(Int,pos[2])
            v = round(Int,pos[1])
            if 1 < u < 480 && 1 < v < 640
                cnt[u,v] += 1f0
                n = cnt[u,v]
                projImg[u,v] =  projImg[u,v]* (n-1)/n + tc.pix/255f0/n
            end
        end

        tags = detector(Gray{N0f8}.(projImg))

        pose = homographytopose(tags[1].H, fx, fy, cx, cy, taglength = 160.)
        display(pose)

        @test all(isapprox.(pose[1:3,1:3], cTw[1:3,1:3], atol = 0.05))
        @test all(isapprox.(pose[1:3,4], cTw[1:3,4], atol = 10.))
    end

end
