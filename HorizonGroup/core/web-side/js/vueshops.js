
const app = new Vue({
    el: '#appshops',
    data: {                
        // FEMININO
        Camisetaf1: [
          {
            label: 'Biquíni',
            default: 0,
            max: 12,
            min: 0,
            id: 'shirtf1'
          }
        ],
        Camisetaf2: [
          {
            label: 'Top',
            default: 0,
            max: 12,
            min: 0,
            id: 'shirtf2'
          }
        ],
        Camisetaf3: [
          {
            label: 'Blusa',
            default: 0,
            max: 20,
            min: 0,
            id: 'shirtf3'
          }
        ],
        Camisetaf4: [
          {
            label: 'Espartilho',
            default: 0,
            max: 16,
            min: 0,
            id: 'shirtf4'
          }
        ],
        Camisetaf5: [
          {
            label: 'Camiseta',
            default: 0,
            max: 35,
            min: 0,
            id: 'shirtf5'
          }
        ],
        Camisetaf6: [
          {
            label: 'Moletom',
            default: 0,
            max: 35,
            min: 0,
            id: 'shirtf6'
          }
        ],  

        Calcaf1: [
          {
            label: 'Biquíni',
            default: 0,
            max: 12,
            min: 0,
            id: 'pantsf1'
          }
        ],
        Calcaf2: [
          {
            label: 'Básica',
            default: 0,
            max: 16,
            min: 0,
            id: 'pantsf2'
          }
        ],
        Calcaf3: [
          {
            label: 'Academia',
            default: 0,
            max: 31,
            min: 0,
            id: 'pantsf3'
          }
        ],
        Calcaf4: [
          {
            label: 'Cargo',
            default: 0,
            max: 40,
            min: 0,
            id: 'pantsf4'
          }
        ],
        Calcaf5: [
          {
            label: 'Basica 2',
            default: 0,
            max: 6,
            min: 0,
            id: 'pantsf5'
          }
        ],
        Calcaf6: [
          {
            label: 'Short',
            default: 0,
            max: 11,
            min: 0,
            id: 'pantsf6'
          }
        ],


        Sapatof1: [
          {
            label: 'Chinelo',
            default: 0,
            max: 24,
            min: 0,
            id: 'shoesf1'
          }
        ],
        Sapatof2: [
          {
            label: 'Slippers',
            default: 0,
            max: 15,
            min: 0,
            id: 'shoesf2'
          }
        ],
        Sapatof3: [
          {
            label: 'Slippers e meias',
            default: 0,
            max: 21,
            min: 0,
            id: 'shoesf3'
          }
        ],
        Sapatof4: [
          {
            label: 'Tênis 1',
            default: 0,
            max: 16,
            min: 0,
            id: 'shoesf4'
          }
        ],
        Sapatof5: [
          {
            label: 'All Star',
            default: 0,
            max: 55,
            min: 0,
            id: 'shoesf5'
          }
        ],
        Sapatof6: [
          {
            label: 'Tênis 2',
            default: 0,
            max: 23,
            min: 0,
            id: 'shoesf6'
          }
        ],
        Sapatof7: [
          {
            label: 'Salto',
            default: 0,
            max: 16,
            min: 0,
            id: 'shoesf7'
          }
        ],


        Acessoriosf1: [
          {
            label: 'Mochila',
            default: 0,
            max: 28,
            min: 0,
            id: 'Mochilaf'
          }
        ],

        Acessoriosf2: [
          {
            label: 'Relógio 1',
            default: 0,
            max: 4,
            min: 0,
            id: 'relogiof1'
          }
        ],

        Acessoriosf3: [
          {
            label: 'Relógio 2',
            default: 0,
            max: 6,
            min: 0,
            id: 'relogiof2'
          }
        ],

        Acessoriosf4: [
          {
            label: 'Brinco 1',
            default: 0,
            max: 3,
            min: 0,
            id: 'brincof1'
          }
        ],
        Acessoriosf5: [
          {
            label: 'Brinco 2',
            default: 0,
            max: 4,
            min: 0,
            id: 'brincof2'
          }
        ],
        Acessoriosf6: [
          {
            label: 'Brinco 3',
            default: 0,
            max: 3,
            min: 0,
            id: 'brincof3'
          }
        ],
        Acessoriosf7: [
          {
            label: 'Brinco 4',
            default: 0,
            max: 3,
            min: 0,
            id: 'brincof4'
          }
        ],
        Acessoriosf8: [
          {
            label: 'Mascara 1',
            default: 0,
            max: 17,
            min: 0,
            id: 'mascaraf1'
          }
        ],
        Acessoriosf9: [
          {
            label: 'Mascara 2',
            default: 0,
            max: 20,
            min: 0,
            id: 'mascaraf2'
          }
        ],



        // MASCULINO
        Camiseta1: [
          {
            label: 'Regatas',
            default: 0,
            max: 26,
            min: 0,
            id: 'shirt1'
          }
        ],
        Camiseta2: [
          {
            label: 'Blusas',
            default: 0,
            max: 87,
            min: 0,
            id: 'shirt2'
          }
        ],
        Camiseta3: [
          {
            label: 'Moletom',
            default: 0,
            max: 35,
            min: 0,
            id: 'shirt3'
          }
        ],
        Camiseta4: [
          {
            label: 'Jaquetas',
            default: 0,
            max: 32,
            min: 0,
            id: 'shirt4'
          }
        ],
        Calca1: [
          {
            label: 'Jeans',
            default: 0,
            max: 17,
            min: 0,
            id: 'pants1'
          }
        ],
        Calca2: [
          {
            label: 'Academia',
            default: 0,
            max: 31,
            min: 0,
            id: 'pants2'
          }
        ],
        Calca3: [
          {
            label: 'Cargo curta',
            default: 0,
            max: 11,
            min: 0,
            id: 'pants3'
          }
        ],
        Calca4: [
          {
            label: 'Cargo',
            default: 0,
            max: 40,
            min: 0,
            id: 'pants4'
          }
        ],
        Calca5: [
          {
            label: 'Bermuda 1',
            default: 0,
            max: 34,
            min: 0,
            id: 'pants5'
          }
        ],
        Calca6: [
          {
            label: 'Bermuda 2',
            default: 0,
            max: 16,
            min: 0,
            id: 'pants6'
          }
        ],
        Calca7: [
          {
            label: 'Bermuda 3',
            default: 0,
            max: 40,
            min: 0,
            id: 'pants7'
          }
        ],



        Sapato1: [
          {
            label: 'Chinelo',
            default: 0,
            max: 24,
            min: 0,
            id: 'shoes1'
          }
        ],
        Sapato2: [
          {
            label: 'Slippers',
            default: 0,
            max: 15,
            min: 0,
            id: 'shoes2'
          }
        ],
        Sapato3: [
          {
            label: 'Slippers e meias',
            default: 0,
            max: 21,
            min: 0,
            id: 'shoes3'
          }
        ],
        Sapato4: [
          {
            label: 'Tênis 1',
            default: 0,
            max: 16,
            min: 0,
            id: 'shoes4'
          }
        ],
        Sapato5: [
          {
            label: 'All Star',
            default: 0,
            max: 55,
            min: 0,
            id: 'shoes5'
          }
        ],
        Sapato6: [
          {
            label: 'Tênis 2',
            default: 0,
            max: 23,
            min: 0,
            id: 'shoes6'
          }
        ],
        Sapato7: [
          {
            label: 'Botas',
            default: 0,
            max: 31,
            min: 0,
            id: 'shoes7'
          }
        ],


        Acessorios1: [
          {
            label: 'Brinco 1',
            default: 0,
            max: 5,
            min: 0,
            id: 'Brinco1'
          }
        ],
        Acessorios2: [
          {
            label: 'Brinco 2',
            default: 0,
            max: 3,
            min: 0,
            id: 'Brinco2'
          }
        ],
        Acessorios3: [
          {
            label: 'Brinco 3',
            default: 0,
            max: 3,
            min: 0,
            id: 'Brinco3'
          }
        ],
        Acessorios4: [
          {
            label: 'Brinco 4',
            default: 0,
            max: 4,
            min: 0,
            id: 'Brinco4'
          }
        ],
        Acessorios5: [
          {
            label: 'Chapéu',
            default: 0,
            max: 18,
            min: 0,
            id: 'hat'
          }
        ],
        Acessorios6: [
          {
            label: 'Corrente',
            default: 0,
            max: 20,
            min: 0,
            id: 'corrente'
          }
        ],
        Acessorios7: [
          {
            label: 'Colete',
            default: 0,
            max: 1,
            min: 0,
            id: 'colete'
          }
        ],
        Acessorios8: [
          {
            label: 'Óculos 1',
            default: 0,
            max: 8,
            min: 0,
            id: 'oculos1'
          }
        ],
        Acessorios9: [
          {
            label: 'Óculos 2',
            default: 0,
            max: 9,
            min: 0,
            id: 'oculos2'
          }
        ],

        Acessorios10: [
          {
            label: 'Mochila',
            default: 0,
            max: 28,
            min: 0,
            id: 'Mochila'
          }
        ],

        Acessorios11: [
          {
            label: 'Relógio 1',
            default: 0,
            max: 4,
            min: 0,
            id: 'relogio1'
          }
        ],

        Acessorios12: [
          {
            label: 'Relógio 2',
            default: 0,
            max: 6,
            min: 0,
            id: 'relogio2'
          }
        ],

        Acessorios13: [
          {
            label: 'Mascara 1',
            default: 0,
            max: 17,
            min: 0,
            id: 'mascara1'
          }
        ],
        Acessorios14: [
          {
            label: 'Mascara 2',
            default: 0,
            max: 20,
            min: 0,
            id: 'mascara2'
          }
        ],       
    },
});