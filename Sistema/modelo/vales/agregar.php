<?PHP
    /*
        Que hace:
            Agregar un vale en la base de datos ejecutando una consulta a un procedimiento almacenado en la base de datos
        Procedimiento:
    */
    /* Intenta abrir una conexion con la base de datos y jecutar una consulta */
    try
    {
        include '../conexion.php';

        /* Prepara una llamada a un procedimiento almacenado preparandolo en la variable preparada */
        $preparada = $conexion->prepare( "CALL agregar_vale( :id, :rfc_distribuidor, :rfc_cliente, :valor_inicial, :quincenas, :tasa, :abono );" );
        /* Agrega los parametros a la consulta preparada */
        $preparada->bindValue( ":id", $_POST[ "id" ] );
        $preparada->bindValue( ":rfc_distribuidor", $_POST[ "rfc_distribuidor" ] );
        $preparada->bindValue( ":rfc_cliente", $_POST[ "rfc_cliente" ] );
        $preparada->bindValue( ":valor_inicial", $_POST[ "valor_inicial" ] );
        $preparada->bindValue( ":quincenas", $_POST[ "quincenas" ] );
        $preparada->bindValue( ":tasa", $_POST[ "tasa" ] );
        $preparada->bindValue( ":abono", $_POST[ "abono" ] );
        
        /*
            Ejecuta la consulta preparada, si regresa false significa que algo salio mal,
            y entra al if mandando un erro con el mensaje del error ocurrido
        */
        if( !$preparada->execute() )
        {
            throw new PDOException( $preparada->errorInfo()[2] );
        }
        
        /* Si todo salio bien regresa la informacion debida */
        echo "Vale agregado";
    }
    /* Si ocurre algun error al conectar o realizar una consulta a la base de datos retorna el mensaje de error */
    catch( PDOException $error )
    {
        echo $error->getMessage();
    }
?>
