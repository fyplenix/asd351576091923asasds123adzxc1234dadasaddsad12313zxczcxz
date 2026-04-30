
const app = new Vue({
    el: '#app',
    data: {        
        Blusas: [
          {
            label: 'Camiseta',
            default: 0,
            max: 8,
            min: 0,
            id: 'Camiseta'
          }
        ],
        Faces: [
          {
            label: 'Formato do rosto',
            default: 1,
            max: 5,
            min: 1,
            id: 'Faces'
          }
        ],
        Rostos: [
          {
            image: 1,
            id: 11
          },
          {
            image: 2,
            id: 12
          },
          {
            image: 3,
            id: 13
          },
          {
            image: 4,
            id: 14
          },
          {
            image: 5,
            id: 15
          },
          {
            image: 6,
            id: 16
          },
          {
            image: 7,
            id: 17
          },
          {
            image: 8,
            id: 18
          },
          {
            image: 9,
            id: 19
          },
          {
            image: 10,
            id: 110
          },
          {
            image: 11,
            id: 111
          },
          {
            image: 12,
            id: 112
          },
          {
            image: 13,
            id: 113
          },
          {
            image: 14,
            id: 114
          },
          {
            image: 15,
            id: 115
          },
          {
            image: 16,
            id: 116
          },
          {
            image: 17,
            id: 117
          },
          {
            image: 18,
            id: 118
          },
          {
            image: 19,
            id: 119
          },
          {
            image: 20,
            id: 120
          },
          {
            image: 21,
            id: 121
          },
          {
            image: 22,
            id: 122
          },
          {
            image: 23,
            id: 123
          },
          {
            image: 24,
            id: 124
          },
          {
            image: 25,
            id: 125
          },
        ],         
        RostosF: [
          {
            image: 1,
            id: 21
          },
          {
            image: 2,
            id: 22
          },
          {
            image: 3,
            id: 23
          },
          {
            image: 4,
            id: 24
          },
          {
            image: 5,
            id: 25
          },
          {
            image: 6,
            id: 26
          },
          {
            image: 7,
            id: 27
          },
          {
            image: 8,
            id: 28
          },
          {
            image: 9,
            id: 29
          },
          {
            image: 10,
            id: 210
          },
          {
            image: 11,
            id: 211
          },
          {
            image: 12,
            id: 212
          },
          {
            image: 13,
            id: 213
          },
          {
            image: 14,
            id: 214
          },
          {
            image: 15,
            id: 215
          },
          {
            image: 16,
            id: 216
          },
          {
            image: 17,
            id: 217
          },
          {
            image: 18,
            id: 218
          },
          {
            image: 19,
            id: 219
          },
          {
            image: 20,
            id: 220
          },
          {
            image: 21,
            id: 221
          },
          {
            image: 22,
            id: 222
          },
          {
            image: 23,
            id: 223
          },
          {
            image: 24,
            id: 224
          },
          {
            image: 25,
            id: 225
          },
        ],          
        Genetica: [
          {
            label: 'Pele',
            default: 0,
            max: 5,
            min: 0,
            id: 'piel'
          }
        ],                                                          
        Pelo: [
          {
            label: 'Cabelo',
            default: 0,
            max: 6,
            min: 0,
            id: 'hair'
          },          
        ],
        Maquiagem: [
          {
            label: 'Maquiagem',
            default: 0,
            max: 26,
            min: 0,
            id: 'Maquiagem'
          },          
        ],
        PelosColor: [
          {
            color: '#271c16',
            value: 1,
            id: 'p1'
          },
          {
            color: '#3b2d21',
            value: 2,
            id: 'p2'
          },
          {
            color: '#593a28',
            value: 3,
            id: 'p3'
          },
          {
            color: '#655641',
            value: 4,
            id: 'p4'
          },
          {
            color: '#131313',
            value: 5,
            id: 'p5'
          },
          {
            color: '#203933',
            value: 6,
            id: 'p6'
          },
          {
            color: '#580004',
            value: 7,
            id: 'p7'
          },
          {
            color: '#700055',
            value: 8,
            id: 'p8'
          },
          {
            color: '#b3b3b3',
            value: 9,
            id: 'p9'
          }
        ],        
        Sobrancelhas: [
          {
            label: 'Sobrancelhas',
            default: 0,
            max: 54,
            min: 0,
            id: 'Sobrancelhas'
          }          
        ],
        SobrancelhasColor: [
          {
            color: '#272727',
            value: 1,
            id: 'sb1'
          },
          {
            color: '#664614',
            value: 2,
            id: 'sb2'
          },
          {
            color: '#9B6511',
            value: 3,
            id: 'sb3'
          },
          {
            color: '#FFBF93',
            value: 4,
            id: 'sb4'
          },          
          {
            color: '#E6E6E6',
            value: 5,
            id: 'sb6'
          },
          {
            color: '#FF2D2D',
            value: 6,
            id: 'sb7'
          },
          {
            color: '#1D6FFF',
            value: 7,
            id: 'sb8'
          },
          {
            color: '#00813C',
            value: 8,
            id: 'sb9'
          },
          {
            color: '#8C009B',
            value: 9,
            id: 'sb10'
          } 
        ],  
        Maquillaje: [
          {
            label: 'Eyeshadow / Face Shape',
            default: 0,
            max: 71,
            min: 0,
            id: 'makeuptype'
          },
          {
            label: 'Makeup thickness',
            default: 0,
            max: 10,
            min: 0,
            id: 'makeupintensidad'
          }
        ],
        Pintalabios: [
          {
            label: 'Lip makeup shape',
            default: 0,
            max: 9,
            min: 0,
            id: 'lipsticktype'
          },
          {
            label: 'Lipstick thickness',
            default: 0,
            max: 32,
            min: 0,
            id: 'lipstickintensidad'
          }
        ],
        Colorete: [
          {
            label: 'Blush makeup shape',
            default: 0,
            max: 9,
            min: 0,
            id: 'blushtype'
          },
          {
            label: 'Makeup thickness',
            default: 0,
            max: 10,
            min: 0,
            id: 'blushintensidad'
          }
        ],
        Barba: [
          {
            label: 'Barba',
            default: 0,
            max: 54,
            min: 0,
            id: 'barba'
          }
        ],
        BarbaColor: [
          {
            color: '#272727',
            value: 1,
            id: 'b1'
          },
          {
            color: '#664614',
            value: 2,
            id: 'b2'
          },
          {
            color: '#9B6511',
            value: 3,
            id: 'b3'
          },
          {
            color: '#FFBF93',
            value: 4,
            id: 'b4'
          },          
          {
            color: '#E6E6E6',
            value: 5,
            id: 'b6'
          },
          {
            color: '#FF2D2D',
            value: 6,
            id: 'b7'
          },
          {
            color: '#1D6FFF',
            value: 7,
            id: 'b8'
          },
          {
            color: '#00813C',
            value: 8,
            id: 'b9'
          },
          {
            color: '#8C009B',
            value: 9,
            id: 'b10'
          } 
        ],  
        MaquillajeColor: [

          {
            color: '#363535',
            value: 27,
            id: 'mc2',
            id2: 'mcc2'
          },
          {
            color: '#636363',
            value: 28,
            id: 'mc3',
            id2: 'mcc3'
          },
          {
            color: '#9528a8',
            value: 33,
            id: 'mc4',
            id2: 'mcc4'
          },
          {
            color: '#ba2f80',
            value: 34,
            id: 'mc5',
            id2: 'mcc5'
          },
          {
            color: '#f246ea',
            value: 35,
            id: 'mc6',
            id2: 'mcc6'
          },{
            color: '#329cc7',
            value: 36,
            id: 'mc7',
            id2: 'mcc7'
          },{
            color: '#1d4f63',
            value: 38,
            id: 'mc8',
            id2: 'mcc8'
          },{
            color: '#204f15',
            value: 42,
            id: 'mc9',
            id2: 'mcc9'
          },{
            color: '#75b32e',
            value: 43,
            id: 'mc10',
            id2: 'mcc10'
          },{
            color: '#a38c48',
            value: 45,
            id: 'mc11',
            id2: 'mcc11'
          },{
            color: '#bf570d',
            value: 47,
            id: 'mc12',
            id2: 'mcc12'
          },{
            color: '#bf0d0d',
            value: 50,
            id: 'mc13',
            id2: 'mcc13'
          },{
            color: '#6e1a1a',
            value: 53,
            id: 'mc14',
            id2: 'mcc14'
          },{
            color: '#000000',
            value: 61,
            id: 'mc15',
            id2: 'mcc15'
          },
        ],
        PintalabiosColor: [

          {
            color: '#594933',
            value: 4,
            id: 'lc2'
          },
          {
            color: '#877050',
            value: 6,
            id: 'lc3'
          },
          {
            color: '#696969',
            value: 26,
            id: 'lc4'
          },
          {
            color: '#ffffff',
            value: 29,
            id: 'lc5'
          },
          {
            color: '#916294',
            value: 30,
            id: 'lc6'
          },
          {
            color: '#000000',
            value: 61,
            id: 'lc7'
          },
          {
            color: '#3d3d3d',
            value: 58,
            id: 'lc8'
          },
          {
            color: '#82302e',
            value: 54,
            id: 'lc9'
          },
          {
            color: '#d10700',
            value: 53,
            id: 'lc10'
          },
          {
            color: '#d18f00',
            value: 52,
            id: 'lc11'
          },
          {
            color: '#f0c465',
            value: 51,
            id: 'lc12'
          },
          {
            color: '#9e9b4d',
            value: 47,
            id: 'lc13'
          },
          {
            color: '#14b824',
            value: 44,
            id: 'lc14'
          },
          {
            color: '#91ed9a',
            value: 42,
            id: 'lc15'
          },
          {
            color: '#1947c2',
            value: 38,
            id: 'lc16'
          },
          {
            color: '#7ea0fc',
            value: 36,
            id: 'lc17'
          },
          {
            color: '#f598d0',
            value: 35,
            id: 'lc18'
          },
          {
            color: '#e00087',
            value: 34,
            id: 'lc19'
          },
          {
            color: '#9c1f6a',
            value: 33,
            id: 'lc20'
          },
        ],
        ColoreteColor: [
          {
            color: '#ff8cf7',
            value: 3,
            id: 'bc2'
          },
          {
            color: '#f2e1d0',
            value: 7,
            id: 'bc3'
          },
          {
            color: '#fff5eb',
            value: 8,
            id: 'bc4'
          },
          {
            color: '#ffffff',
            value: 9,
            id: 'bc5'
          },
          {
            color: '#fcf0fc',
            value: 10,
            id: 'bc6'
          },
          {
            color: '#f7b763',
            value: 12,
            id: 'bc7'
          },
          {
            color: '#ff9100',
            value: 13,
            id: 'bc8'
          },
          {
            color: '#8a8348',
            value: 49,
            id: 'bc9'
          },
          {
            color: '#3b3a3a',
            value: 62,
            id: 'bc10'
          },
          {
            color: '#000000',
            value: 63,
            id: 'bc11'
          },
          {
            color: '#802d2d',
            value: 21,
            id: 'bc12'
          },
          {
            color: '#ff0000',
            value: 22,
            id: 'bc13'
          },
          {
            color: '#ff6e6e',
            value: 5,
            id: 'bc14'
          },
        ],        
        
        RegataInicial: [
          {
            label: 'Camisa inicial',
            default: 0,
            max: 5,
            min: 1,
            id: 'regatainicial'
          }
        ],

        BermudaInicial: [
          {
            label: 'Bermuda inicial',
            default: 0,
            max: 5,
            min: 1,
            id: 'bermudainicial'
          }
        ]

    },
});