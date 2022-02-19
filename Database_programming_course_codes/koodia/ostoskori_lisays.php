<?php
// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot)) {
    die("Tietokantayhteyden luominen epäonnistui.");
}

session_start();
if (isset($_POST['lisaa'])) {
    $nideid = $_POST['lisaa'];
    
    // Etsitään kirjan tiedot tietokannasta
    $kysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Id = Nide.Teos_id AND Nide.Id = $nideid";
    $tulos = pg_query($kysely);
    while ($row = pg_fetch_row($tulos)) {
        $nimi = $row[0];
        $tekija = $row[1];
        $luokka = $row[2];
        $tyyppi = $row[3];
        $hinta = $row[4];
    }


    echo '<table>';
    echo 'Ostoskoriin lisätty: ';
    // Tulostetaan kirjan tiedot
    echo '<tr><td>Nimi:   </td><td> '              . $nimi      . '</td></tr>';
    echo '<tr><td>Tekijä: </td><td> '              . $tekija    . '</td></tr>';
    echo '<tr><td>Luokka: </td><td> '              . $luokka    . '</td></tr>';
    echo '<tr><td>Tyyppi: </td><td> '              . $tyyppi    . '</td></tr>';
    echo '<tr><td>Hinta:  </td><td> '              . $hinta     . '</td></tr>';

    echo '</table><br />';
        
    // Jos taulukkoa ei vielä ole, luodaan se
    if (!isset($_SESSION['ostoskori'])) {
        // Jos halutaan tuki monelle käyttäjälle, voi tässä kohtaa tallentaa asiakas-id:n
        // taulukon avaimeksi
        $ostoskorilista = array("$nideid");
        $_SESSION['ostoskori'] = $ostoskorilista;
        //print_r($_SESSION['ostoskori']);
    }

    // Lisätään tiedot ostoskori-taulukkoon
    else {
        $lisataan = true;
        // Tarkistetaan, ettei ostoskorista löydy jo samaa nidettä
        foreach ($_SESSION['ostoskori'] as $value) {
            if ($value == $nideid) {
                $lisataan = false;
                header('Location: haku.php');
            }
        }
        
        if ($lisataan == true) {
            // lisätään nide-id
            array_push($_SESSION['ostoskori'], $nideid);
        }
    }
        
    if (isset($_POST['ok'])) {
        // siirrytaan sivulle haku.php
        header('Location: haku.php');
        exit();
    }
}

// jos asiakas painoi "Siirry ostamaan", siirrytään lomakkeella ostamaan.php
elseif (isset($_POST['ostamaan'])) {
    header('Location: ostamaan.php');
    exit();
}

// jos asiakas on painanut "Näytä ostoskori", näytetään ostoskorin sisältö
else {
    // jos ostoskorissa on sisältöä, tulostetaan se
    if (isset($_SESSION['ostoskori'])) {
        foreach ($_SESSION['ostoskori'] as $value) {
            $kysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Id = Nide.Teos_id AND Nide.Id = $value";
            $tulos = pg_query($kysely);
            while ($row = pg_fetch_row($tulos)) {
                echo "<table>";
                $nimi = $row[0];
                echo "Nimi: $nimi ";
                $tekija = $row[1];
                echo "Tekijä: $tekija ";
                $luokka = $row[2];
                echo "Luokka: $luokka ";
                $tyyppi = $row[3];
                echo "Tyyppi: $tyyppi ";
                $hinta = $row[4];
                echo "Hinta: $hinta ";
                
                // lisätään painike, josta käyttäjä voi poistaa tuotteen ostoskorista
                echo "<form action='ostoskori_lisays.php' method='post'>
                <button name='poista' type='submit' value=$value>Poista tuote ostoskorista</button>
                </form>";
                
                echo "</table><br/>";
            }
        }
    }
    
    if (isset($_POST['ok'])) {
        // siirrytaan sivulle haku.php
        header('Location: haku.php');
    }
}

// jos käyttäjä painoi poista-nappia, poistetaan tuote ostoskorista
if (isset($_POST['poista'])) {
    // poistetaan id listalta
    if (($key = array_search($_POST['poista'], $_SESSION['ostoskori'])) !== false) {
        unset($_SESSION['ostoskori'][$key]);
    }
    echo "Poistaminen onnistui.";
}


// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
    <head>
        <title>Ostoskoriin lisäys</title>
    </head>
    <body>
        <form method="post" action="ostoskori_lisays.php">
            <input type="submit" name ="ok" value="Ok"/>
        <tr>
            <td></td>
            <td><input type="submit" name="ostamaan" value="Siirry ostamaan"/></td>
        </tr>
        </form>
    </body>
</html>