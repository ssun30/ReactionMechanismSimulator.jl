using Test
using Unitful

include("Rate.jl")
include("../Constants.jl")

#Arrhenius testing
arr = Arrhenius(A=1e6,n=0.5,Ea=41.84*1000.0)
Tlist = 200:200:2000
@test [arr(T=T) for T in Tlist] ≈ [1.6721e-4, 6.8770e1, 5.5803e3, 5.2448e4, 2.0632e5, 5.2285e5, 1.0281e6, 1.7225e6, 2.5912e6, 3.6123e6] rtol=1e-3

#PDepArrhenius testing
arr1 = Arrhenius(A=1e6,n=1.0,Ea=10.0*1000.0)
arr2 = Arrhenius(A=1e12,n=1.0,Ea=20.0*1000.0)
Ps = [0.1,10.0].*1e5
parr = PdepArrhenius(Ps=Ps,arrs=[arr1,arr2])
Tlist = 300:100:1500
Plist = [1e4,1e6,1e5]

parr.arrs[1](T=800.0)
parr(T=800.0,P=1.0e5)


for q = 1:3
    P = Plist[q]
    if q == 1
        for T in Tlist
            @test parr(T=T,P=P) ≈ parr.arrs[1](T=T) rtol=1e-5
        end
    elseif q == 2
        for T in Tlist
            @test parr(T=T,P=P) ≈ parr.arrs[2](T=T) rtol=1e-5
        end
    else
        for T in Tlist
            @test parr(T=T,P=P) ≈ sqrt(parr.arrs[1](T=T)*parr.arrs[2](T=T))  rtol=1e-5
        end
    end
end

#MultiArrhenius testing
marr = MultiArrhenius(arrs=[arr1,arr2])
@test marr(T=900.0) ≈ arr1(T=900.0)+arr2(T=900.0) rtol=1e-6

#MultiPdepArrhenius testing
arr1 = Arrhenius(A=upreferred((9.3e-16*Na)u"cm^3/(mol*s)").val,n=0.0,Ea=upreferred((4740.0*R*0.001)u"kJ/mol").val)
arr2 = Arrhenius(A=upreferred((9.3e-14*Na)u"cm^3/(mol*s)").val,n=0.0,Ea=upreferred((4740.0*R*0.001)u"kJ/mol").val)
arr3 = Arrhenius(A=upreferred((1.4e-11*Na)u"cm^3/(mol*s)").val,n=0.0,Ea=upreferred((11200.0*R*0.001)u"kJ/mol").val)
arr4 = Arrhenius(A=upreferred((1.4e-9*Na)u"cm^3/(mol*s)").val,n=0.0,Ea=upreferred((11200.0*R*0.001)u"kJ/mol").val)
Ps = [0.1,10.0].*1e5
parr1 = PdepArrhenius(Ps=Ps,arrs=[arr1,arr2])
parr2 = PdepArrhenius(Ps=Ps,arrs=[arr3,arr4])
mparr = MultiPdepArrhenius(parrs=[parr1,parr2])

Tlist = [200,400,600,800,1000,1200,1400,1600,1800,2000]
Plist = [1e4,1e5,1e6]

kexplist = [
            [2.85400e-08 4.00384e-03 2.73563e-01 8.50699e+00 1.20181e+02 7.56312e+02 2.84724e+03 7.71702e+03 1.67743e+04 3.12290e+04];
            [2.85400e-07 4.00384e-02 2.73563e+00 8.50699e+01 1.20181e+03 7.56312e+03 2.84724e+04 7.71702e+04 1.67743e+05 3.12290e+05];
            [2.85400e-06 4.00384e-01 2.73563e+01 8.50699e+02 1.20181e+04 7.56312e+04 2.84724e+05 7.71702e+05 1.67743e+06 3.12290e+06];
        ]
for i = 1:length(Tlist)
    for j = 1:length(Plist)
        kexp = kexplist[j,i]
        kact = mparr(T=Tlist[i],P=Plist[j])
        @test kact ≈ kexp rtol=1e-3
    end
end