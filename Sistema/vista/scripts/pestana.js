/* Variable para guardar el boton de pestana seleccionado actualmente */
var button_seleccionado;
/* Variable para guarder el iframe que sera visible actualmente */
var iframe_seleccionado;

/*
    Que hace:
        Selecciona y hace visibles al button y iframe pasado por parametro y deselecciona y hace invisible al button e iframe anterior
    Parametros:
        button es el nuevo button a marcar como pestana seleccionada
        iframe es el nuevo iframe a marcar como visible
    Funcionamiento:
*/
function cambiar_seccion( button, iframe )
{
    /* Si el boton es diferente al que ya esta seleccionado entra al if */
    if( button != button_seleccionado )
    {
        /*
            Le quitamos la clase de pestana-selecionada al boton guardado actualmente en la variable butto_seleccionado
            para que se le aplique un estilo css de desseleccionado
        */
        button_seleccionado.classList.remove("pestana-seleccionada");
        /*
            Le agregamos la clase de contenedor-deseleccionado al iframe guardado actualmente en la variable iframe_seleccionado
            para aplicarle un estilo css que lo dejara de mostrar en el documento
        */
        iframe_seleccionado.classList.add("contenedor-deseleccionado");
        /*
            Cambiamos el boton seleccionado y el iframe seleccionado por los pasados por argumento
        */
        button_seleccionado = button;
        iframe_seleccionado = iframe;
        /*
            Le agregamos la clase de pestana-selecionada al boton guardado actualmente en la variable butto_seleccionado
            para que se le aplique un estilo css de seleccionado
        */
        button_seleccionado.classList.add("pestana-seleccionada");
        /*
            Le removemos la clase de contenedor-deseleccionado al iframe guardado actualmente en la variable iframe_seleccionado
            para aplicarle un estilo css que lo muestre en el documento
        */
        iframe_seleccionado.classList.remove("contenedor-deseleccionado");
    }
}

window.onload = function()
{
    /* Buscamos en el documento el boton con la clase pestana-selecionada y lo guardamos en la variable button_selecionado */
    button_seleccionado = document.querySelector("button[class=pestana-seleccionada]");
    /* Buscamos en el documento el iframe que inicie con la id contendeor-seccion que no tenga la clase contenedor-deseleccionado */
    iframe_seleccionado = document.querySelector('iframe[id^="contenedor-seccion"]:not([class~="contenedor-deseleccionado"])');
};
