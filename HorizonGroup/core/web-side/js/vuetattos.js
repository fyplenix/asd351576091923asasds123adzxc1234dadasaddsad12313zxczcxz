
const app = new Vue({
    el: '#apptattos',
    data: {                        
        //Feminino
        //PERNAS
        TattoPernaEsquerdaF: [
            {
              label: 'Perna esquerda',
              default: 0,
              max: 26,
              min: 0,
              id: 'TattoPernaEsquerdaF'
            }
        ],
        TattoPernaDireitaF: [
            {
              label: 'Perna direita',
              default: 0,
              max: 26,
              min: 0,
              id: 'TattoPernaDireitaF'
            }
        ],

        //BRACOS
        TattoBracoEsquerdoF: [
            {
              label: 'Braço esquerdo',
              default: 0,
              max: 38,
              min: 0,
              id: 'TattoBracoEsquerdoF'
            }
        ],
        TattoBracoDireitoF: [
            {
              label: 'Braço direito',
              default: 0,
              max: 38,
              min: 0,
              id: 'TattoBracoDireitoF'
            }
        ],

        //COSTAS
        TattoCostasF: [
            {
              label: 'Costas',
              default: 0,
              max: 33,
              min: 0,
              id: 'TattoCostasF'
            }
        ],
        
        //PEITO
        TattoPeitoF: [
            {
              label: 'Peito',
              default: 0,
              max: 30,
              min: 0,
              id: 'TattoPeitoF'
            }
        ],



        //Masculino
        //PERNAS
        TattoPernaEsquerdaM: [
            {
              label: 'Perna esquerda',
              default: 0,
              max: 26,
              min: 0,
              id: 'TattoPernaEsquerdaM'
            }
        ],
        TattoPernaDireitaM: [
            {
              label: 'Perna direita',
              default: 0,
              max: 26,
              min: 0,
              id: 'TattoPernaDireitaM'
            }
        ],

        //BRACOS
        TattoBracoEsquerdoM: [
            {
              label: 'Braço esquerdo',
              default: 0,
              max: 38,
              min: 0,
              id: 'TattoBracoEsquerdoM'
            }
        ],
        TattoBracoDireitoM: [
            {
              label: 'Braço direito',
              default: 0,
              max: 38,
              min: 0,
              id: 'TattoBracoDireitoM'
            }
        ],

        //COSTAS
        TattoCostasM: [
            {
              label: 'Costas',
              default: 0,
              max: 16,
              min: 0,
              id: 'TattoCostasM'
            }
        ],
        
        //PEITO
        TattoPeitoM: [
            {
              label: 'Peito',
              default: 0,
              max: 25,
              min: 0,
              id: 'TattoPeitoM'
            }
        ],

    }
})