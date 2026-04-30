
const app = new Vue({
    el: '#police',
    data: {        
    //////////////////////////////////////////////////////////////////                
    //MASCULINO
    //////////////////////////////////////////////////////////////////
        //CAMISA
        Camisa1M: [
            {
              label: 'Blusa estilo 1',
              default: 0,
              max: 2,
              min: 0,
              id: 'Camisa1M'
            }
        ],
        Camisa2M: [
            {
              label: 'Blusa estilo 2',
              default: 0,
              max: 1,
              min: 0,
              id: 'Camisa2M'
            }
        ],
        Camisa3M: [
            {
              label: 'Blusa estilo 3',
              default: 0,
              max: 9,
              min: 0,
              id: 'Camisa3M'
            }
        ],
        Camisa4M: [
            {
              label: 'Blusa estilo 4',
              default: 0,
              max: 11,
              min: 0,
              id: 'Camisa4M'
            }
        ],
        
        //CALÇA
        Calca1M: [
            {
              label: 'Calca estilo 1',
              default: 0,
              max: 7,
              min: 0,
              id: 'Calca1M'
            }
        ],
        Calca2M: [
            {
              label: 'Calca estilo 2',
              default: 0,
              max: 2,
              min: 0,
              id: 'Calca2M'
            }
        ],

        //BOTA
        Bota1M: [
            {
              label: 'Sapato estilo 1',
              default: 0,
              max: 1,
              min: 0,
              id: 'Bota1M'
            }
        ],
        Bota2M: [
            {
              label: 'Sapato estilo 2',
              default: 0,
              max: 1,
              min: 0,
              id: 'Bota2M'
            }
        ],

        //COLETE
        Colete1M: [
            {
              label: 'Colete estilo 1',
              default: 0,
              max: 3,
              min: 0,
              id: 'Colete1M'
            }
        ],
        Colete2M: [
            {
              label: 'Colete estilo 2',
              default: 0,
              max: 2,
              min: 0,
              id: 'Colete2M'
            }
        ],
        Colete3M: [
            {
              label: 'Colete estilo 3',
              default: 0,
              max: 6,
              min: 0,
              id: 'Colete3M'
            }
        ],


        //Chapeu
        Chapeu1M: [
            {
              label: 'Chapeu estilo 1',
              default: 0,
              max: 7,
              min: 0,
              id: 'Chapeu1M'
            }
        ],
        Chapeu2M: [
            {
              label: 'Chapeu estilo 2',
              default: 0,
              max: 2,
              min: 0,
              id: 'Chapeu2M'
            }
        ],
        Chapeu3M: [
            {
              label: 'Chapeu estilo 3',
              default: 0,
              max: 3,
              min: 0,
              id: 'Chapeu3M'
            }
        ],

        // CINTO
        Cinto1M: [
            {
              label: 'Cinto estilo 1',
              default: 0,
              max: 1,
              min: 0,
              id: 'Cinto1M'
            }
        ],



    //////////////////////////////////////////////////////////////////                
    //FEMININO
    //////////////////////////////////////////////////////////////////
        //CAMISA
        Camisa1F: [
            {
              label: 'Blusa estilo 1',
              default: 0,
              max: 2,
              min: 0,
              id: 'Camisa1F'
            }
        ],
        Camisa2F: [
            {
              label: 'Blusa estilo 2',
              default: 0,
              max: 1,
              min: 0,
              id: 'Camisa2F'
            }
        ],
        Camisa3F: [
            {
              label: 'Blusa estilo 3',
              default: 0,
              max: 9,
              min: 0,
              id: 'Camisa3F'
            }
        ],
        Camisa4F: [
            {
              label: 'Blusa estilo 4',
              default: 0,
              max: 11,
              min: 0,
              id: 'Camisa4F'
            }
        ],

        //CALÇA
        Calca1F: [
            {
              label: 'Calca estilo 1',
              default: 0,
              max: 7,
              min: 0,
              id: 'Calca1F'
            }
        ],
        Calca2F: [
            {
              label: 'Calca estilo 2',
              default: 0,
              max: 2,
              min: 0,
              id: 'Calca2F'
            }
        ],

        //BOTA
        Bota1F: [
            {
              label: 'Sapato estilo 1',
              default: 0,
              max: 1,
              min: 0,
              id: 'Bota1F'
            }
        ],
        Bota2F: [
            {
              label: 'Sapato estilo 2',
              default: 0,
              max: 1,
              min: 0,
              id: 'Bota2F'
            }
        ],

        //COLETE
        Colete1F: [
            {
              label: 'Colete estilo 1',
              default: 0,
              max: 3,
              min: 0,
              id: 'Colete1F'
            }
        ],
        Colete2F: [
            {
              label: 'Colete estilo 2',
              default: 0,
              max: 2,
              min: 0,
              id: 'Colete2F'
            }
        ],
        Colete3F: [
            {
              label: 'Colete estilo 3',
              default: 0,
              max: 6,
              min: 0,
              id: 'Colete3F'
            }
        ],

        //Chapeu
        Chapeu1F: [
            {
              label: 'Chapeu estilo 1',
              default: 0,
              max: 2,
              min: 0,
              id: 'Chapeu1F'
            }
        ],
        Chapeu2F: [
            {
              label: 'Chapeu estilo 2',
              default: 0,
              max: 3,
              min: 0,
              id: 'Chapeu2F'
            }
        ],
        
        // CINTO
        Cinto1F: [
            {
              label: 'Cinto estilo 1',
              default: 0,
              max: 1,
              min: 0,
              id: 'Cinto1F'
            }
        ],
    }
})