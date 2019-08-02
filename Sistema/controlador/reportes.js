/*
    Que hace:
        Cuando carga la pagina se llama por medio de XMLHttpRequest a una URL que esta en la etiqueta html con el atributo [data-action]
        Despues se muestran los resultados en la etiqueta con la id tabala de la pagina
    Funcionamiento:
*/
/* Sobre escribimos el metodo al que se llama cuando la pagina termina de cargar */
window.onload = function()
{
    /* 
        Creamos una objecto XMLHttpRequest llamado xhttp que nos permitira enviar la cabezera una pagina y
        obtener una respuesta sin refrescar la pagina    
    */
    var xhttp = new XMLHttpRequest();
    /* Esta funcion sera llamada de manera asincrona cada vez que la variable xhttp.readyState cambie de valor */
    xhttp.onreadystatechange = function()
    {
        /* Cuando termina de cargar la respuesta de la pagina entra al if */
        if( xhttp.readyState == 4 )
        {
            /* Si la respuesta fue exitosa segun el protocolo http entra al if */
            if( xhttp.status == 200 )
            {
                /*
                    Probamos si la respuesta es un arreglo de JSON's,
                    Si se recibe un arreglo de JSON's quiere decir que es el resultado de una consulta
                */
                try
                {
                    /* Recorremos todos los JSON's en el erreglo */
                    JSON.parse( xhttp.responseText ).forEach
                    (
                        /* Esta funcion sera llamda por cada JSON pasandolo como parametro */
                        function( objecto )
                        {
                            /* Recorremos todas las llaves del objeto JSON pasandolo como parametro */
                            Object.keys( objecto ).forEach
                            (
                                /* Esta funcion es llamada por cada llave del JSON pasandola como argimento */
                                function( llave )
                                {
                                    /*
                                        Buscamos la etiqueta con la id tabla en el documento html y le agregamos contenido html,
                                        igual al el valor de la llave pasada por argumento
                                        dentro una etiqueta p que esta dentro de un div con la clase fila
                                    */
                                    document.getElementById("tabla").innerHTML += '<div class="fila" ><p>' + objecto[llave] + '</p></div>';
                                }
                            );
                        }
                    );
                }
                /* Si no es un arreglo de JSON's mostramos el retorno como un mensaje */
                catch( e )
                {
                    alert( xhttp.responseText );
                }
            }
            /* Si la respuesta no fue exitosa se mostrara el codigo de error http */
            else
            {
                alert( "Error HTTP: " + xhttp.status );
            }
        }
    };
    /*
        Se busca a la etiqueta con el atributo "data-action" y se obtiene su valor el cual es un URL
        para indicarle al objecto http a que pagina enviara la informacion
    */
    xhttp.open("GET", document.querySelector("[data-action]").dataset.action, true);
    /* Enviamos la informacion a la pagina */
    xhttp.send();

    /* Ponemos la fecha actual dentro del contenido html de la etiqueta con la id fecha y dentro de su h2 usando la clase Date */
    var fecha = new Date();
    document.querySelector( '[id="fecha"] h2' ).innerHTML = fecha.getFullYear() + " / " + ( fecha.getMonth() + 1 ) + " / " + fecha.getDate();
}
