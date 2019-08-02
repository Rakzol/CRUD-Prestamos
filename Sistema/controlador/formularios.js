/*
    Variable para guardar los resultados de las consultas, en un array donde cada elemento es
    un json que usa como llave el nombre de la columna de la tabla de la base de datos:
    [
        { "nombre_columna": valor, "nombre_columna": valor }, <- Primera fila
        { "nombre_columna": valor, "nombre_columna": valor } <- Segunda fila
    ]
*/
var filas;
/* Hacemos que cuando la pagina termine de cargar llame a una funcion */
window.addEventListener
(
    "load",
    /*
        Que hace:
            Cuando carga la pagina sobre escribe el metodo onsubmit del primer formulario para enviarlo por XMLHttpRequest
            y mostrar el retorno como mensaje o guardando el resultado de una consulta en la variable filas y mostrandolo
            llamando a la funcion indice(1);
        Funcionamiento:
    */
    function()
    {
        /* Se busca a el primer formulario en el documento y se sobrescribimos el la función onsubmit */
        document.getElementsByTagName("form")[0].onsubmit = function()
        {
            /* Preguntamos si el usuario esta seguro de enviar el formulario y si acepta entra al if */
            if( confirm("¿Quiere enviar el formulario?") )
            {
                /* Variable para guardar una cabezera del protocolo http llave=valor& */
                var cuerpo = "";
                /* Recorremos cada uno de los inputs del formulario que no sean botones */
                this.querySelectorAll("input:not([type='submit']):not([type='button']):not([type='reset']), select").forEach
                (
                    /* Esta funcion sera llamada por cada input que nosea boton pasandolo como parametro */
                    function( input )
                    {
                        /* Sacamos el nombre del input y lo guardamos en la variable cuerpo para crear la llave de la cabezera http */
                        cuerpo += "&" + input.name + "=";
                        /* Sino esta deshabilitado el input sacamos su valor para creare el valor de la cabezera http */
                        if( !input.disabled )
                        {
                            cuerpo += ( input.type != "checkbox" ) ? input.value : input.checked ;
                        }
                        /* Si esta deshabilitado le ponemos un valor por defecto en la cabezera */
                        else
                        {
                            switch ( input.type )
                            {
                                case "number":
                                    cuerpo += 0;
                                break;
                                case "checkbox":
                                    cuerpo += input.checked;
                                break;
                                case "date":
                                    cuerpo += "0-0-0";
                                case "select-one":
                                    cuerpo += input.value;
                                break;
                            }
                        }
                    }
                );

                /* 
                    Creamos una objecto XMLHttpRequest llamado xhttp que nos permitira enviar la cabezeraa una pagina y
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
                                /* Si el arreglo contiene mas de 0 JSON's */
                                if( JSON.parse( xhttp.responseText ).length > 0 )
                                {
                                    /* Le notificamos al usuario que se encontraron datos al realizar la consulta */
                                    alert("Resultados actualizados");
                                    /* Guardamos el arreglo de JSON's en la variable filas */
                                    filas = JSON.parse( xhttp.responseText );
                                    /*
                                        Buscamos la etiqueta html del documento con la id cantidad
                                        donde guardamos la cantidad de filas encontrdas y la actualizamos
                                    */
                                    document.getElementById( "cantidad" ).innerHTML = filas.length;
                                    /* 
                                        Llamamos a la funcion indice para ir a la primera fila de la consulta realizada
                                        que se reflejara en el segundo formulario del documento
                                    */
                                    indice( 1 );
                                }
                                /* Si era un arreglo de JSON's pero esta vacio la consulta no encontro nada */
                                else
                                {
                                    alert("No se encontraron coincidencias");
                                }
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
                /* Le indicamos al objecto http a que pagina enviara la informacion la cual es el action del formulario */
                xhttp.open("POST", this.action, true);
                /* Le decimos al objeto xhttp que usara el protocolo http llave=valor& */
                xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                /*
                    Por ultimo hacemos el envio de la informacion a la pagina con la cabezera creada anteriormente,
                    a la cual le quitamos el primer caracter ya que queda como resultado
                    &llave=valor&llave=valor... y despues del cambio queda llave=valor&llave=valor... como tiene que ser
                */
                xhttp.send( cuerpo.slice(1) );
            }
            /* Regresamos false para que el onsubmit no rediriga la pagina al action */
            return false;
        };

    }
);
