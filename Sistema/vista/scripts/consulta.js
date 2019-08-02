/* Hacemos que la pagina llame auna funcion cuando termina de cargar */
window.addEventListener
(
    "load",
    /*
        Que hace:
            Cuando la pagina carga sobre escribe el metodo onreset del primer formulario del documento para solo resetear
            los inputs que no sean botones y sus nombres no inicien con b_, recorre todo los inputs de tipo checkbox que su
            nombre inicie con b_ y sobre su metodo on change para activar o desactivar a los inputs que se llamen igual sin el b_
            dependiendo de su valor en checked
        Funcionamiento:
    */
    function()
    {
        /* También sobre escribimos el método "onreset" del primer formulario que se encuentre en el documento */
        document.getElementsByTagName("form")[0].onreset = function()
        {
            /* Preguntamos si quiere limpiar el formuilario, si acepta entra al if */
            if( confirm("¿Quiere limpiar el formulario?") )
            {
                /* Recorremos todos los inputs del formulario que no sean botones y su nombre no inicie con b_ */
                this.querySelectorAll("input:not([type='submit']):not([type='button']):not([type='reset']):not([name^='b_']), select").forEach
                (
                    /* Esta funcion sera llamada con cada uno de los inputs pasandolo como argumento */
                    function( input )
                    {
                        /* Reseteamos el input a un valor por defecto dependiendo de su valor */
                        switch ( input.type )
                        {
                            case "checkbox":
                                input.checked = false;
                            break;
                            case "select-one":
                                input.value = input.children[0].value;
                            break;
                            default:
                                input.value = "";
                            break;
                        }
                    }
                );
            }
            /* Regresamos false para que no resetee todos los inputs */
            return false;
        };

        /* Recorremos todos los inputs del documento de tipo checkbox que inicien con el nombre b_ */
        document.querySelectorAll('input[type="checkbox"][name^="b_"]').forEach
        (
            /* Esta funcion sera llamada por cada input pasandolo como argumento */
            function( checkbox )
            {
                /* Sobre escribimos la funcion onchange del input de tipo checkbox pasandolo como argumento */
                checkbox.onchange = function()
                {
                    /*
                        Buscamos en el documento el input con el nombre que tiene el input de tipo checkbox pasado por parametro,
                        quitandole los dos primero caracteres que son b_ y lo habilitamos o deshabilitamos dependiendo
                        de si esta checkeado el input tipo checkbox pasado por argumento
                    */
                    document.querySelector( '[name="' + checkbox.name.slice(2) + '"]' ).disabled = !checkbox.checked;
                };
            }
        );

    }
);

/*
    Que hace:
        Marca o desmarca todos los inputs checkbox que inicien con b_ dependiendo del parametro
    Parametros:
        estado es un boleano true para marcar o false para desmarcar todos los inputs de tipo checkbox que su nombre inicie con b_
    Funcionamiento:
*/
function cambiar_banderas( estado )
{
    /* Preguntamos si quiere marcar o desmarcar todos los inputs de tipo checkbox si acepta entra al if */
    if( confirm( "¿Quiere " + ( ( estado ) ? "marcar" : "desmarcar" ) + " todas las casillas?" ) )
    {
        /* Recorremos todos los inputs del documento de tipo checkbox que su nombre inicien con b_ */
        document.querySelectorAll('input[type="checkbox"][name^="b_"]').forEach
        (
            /* Esta funcion sera llamada por cada uno de los checkbox pasandolo como argumento */
            function( checkbox )
            {
                /* Marcamos o desmarcamos el checkbox dependiendo de que valia la variable estado */
                checkbox.checked = estado;
                /*
                    Llamamos a su funcion onchange del checkbox para que habilite o deshabilite al input
                    que se llame como el quitando los dos primero caracteres que son b_
                    dependiendo de lo que valia la variable estado
                */
                checkbox.onchange();
            }
        );
    }
}

/*
    Que hace:
        Representa los resultados de fila de la posicion indicada en el segundo formulario del documento
    Parametros:
        posicion es la fila o posicion del arreglos de JSON's guardado en la variable filas
    Funcionamiento:
*/
function indice( posicion )
{
    /* Verificamos que la variable filas no este vacia, sino lo esta entramos al if */
    if( filas != undefined )
    {
        /* Verificamos que la posicion sea una posicion valida para el arreglo sino lo es lo llevaremos a la primera posicion */
        if( isNaN(posicion) || posicion <= 0 || posicion > filas.length )
        {
            /* Asignamos una posicion valida para el arreglo dentro de la variable posicion */
            posicion = 1;
        }
        /* Seleccionamos el segundo formulario del documento y recorremos todos sus inputs que esten solo lecutra o deshabilitados */
        document.getElementsByTagName("form")[1].querySelectorAll("[readonly],[disabled]").forEach
        (
            /* Esta funcion sera llamada por cada input pasandolo como argumento */
            function(input)
            {
                /* Si no el input actual no es de tipo checkbox entra al if */
                if( input.type != "checkbox" )
                {
                    /*
                        Cambia el valor del input por el valor por el del JSON en la posicion pasada por parametro
                        con la llave igual al nombre del input
                    */
                    input.value = filas[ posicion - 1 ][ input.name ];
                }
                /* Si lo es entra al else */
                else
                {
                    /*
                        Cambia el checked del checkbox por el valor por el del JSON en la posicion pasada por parametro
                        con la llave igual al nombre del input comparando si es igual a "1" para que regrese true o false
                    */
                    input.checked = filas[ posicion - 1 ][ input.name ] == "1";
                }
            }
        );
        /*
            Buscamos en el documento la etiqueta con la id posicion que guarda la posicion actual de los resultado de consulta
            y le asignamos el valor de la posicion de donde se saco la informacion guardada en los inputs del segundo formulario
        */
        document.getElementById( "posicion" ).value = posicion;
    }
    /* Si esta vacia entra al if */
    else
    {
        /*
            Buscamos en el documento la etiqueta con la id posicion que guarda la posicion actual de los resultado de consulta
            y le asignamos el valor 0 ya que no existen resultados de consulta
        */
        document.getElementById( "posicion" ).value = 0;
    }
}
