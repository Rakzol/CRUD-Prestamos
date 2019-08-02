<?PHP
    /*
        Que hace:
            Consulta un abono en la base de datos ejecutando una consulta a un procedimiento almacenado en la base de datos
        Procedimiento:
    */
    /* Intenta abrir una conexion con la base de datos y jecutar una consulta */
    try
    {
        include '../conexion.php';

        /* Prepara una llamada a un procedimiento almacenado preparandolo en la variable preparada */
        $preparada = $conexion->prepare( "CALL consultar_abono( :id_vale, :b_id_vale, :fecha, :b_fecha );" );
        /* Agrega los parametros a la consulta preparada */
        $preparada->bindValue( "id_vale", $_POST[ "id_vale" ] );
        $preparada->bindValue( "b_id_vale", $_POST[ "b_id_vale" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "fecha", $_POST[ "fecha" ] );
        $preparada->bindValue( "b_fecha", $_POST[ "b_fecha" ] == "true", PDO::PARAM_BOOL );
        
        /*
            Ejecuta la consulta preparada, si regresa false significa que algo salio mal,
            y entra al if mandando un erro con el mensaje del error ocurrido
        */
        if( !$preparada->execute() )
        {
            throw new PDOException( $preparada->errorInfo()[2] );
        }
        
        /* Si todo salio bien regresa la informacion debida */
        echo json_encode( $preparada->fetchAll( PDO::FETCH_ASSOC ) );
    }
    /* Si ocurre algun error al conectar o realizar una consulta a la base de datos retorna el mensaje de error */
    catch( PDOException $error )
    {
        echo $error->getMessage();
    }
?>
