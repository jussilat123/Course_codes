<?php
// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");
session_start();
// muutetaan kirjan/kirjojen tila vapaasta varatuksi
$asiakasid = intval($_SESSION['asiakasid']);
if (isset($_SESSION['ostoskori'])) {
    // muuttuja, johon lasketaan kirjojen yhteispaino
    $yhteispaino = 0;
    // muuttuja, johon lasketaan tilauksen yhteissumma
    $yhteissumma = 0;
    foreach ($_SESSION['ostoskori'] as $value) {
        // etsitään nide, jolla on vastaava id,
        // ja muutetaan sen tila varatuksi
        $muutos = "UPDATE keskustietokanta.Nide SET tila = 'varattu' WHERE id = $value";
        $paivitys = pg_query($muutos);
    }
    
    // tulostetaan tilauksen tiedot
    echo '<table>';
    echo '<div style="font-size:1.25em;color:black">Tilausvahvistus: </div>';
    echo '<br>';
    foreach ($_SESSION['ostoskori'] as $value) {
        // 
        $tiedotkysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Paino FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Id = Nide.Teos_id AND Nide.ID = $value";
        $tiedot = pg_query($tiedotkysely);
        while ($row = pg_fetch_row($tiedot)) {
            $nimi = $row[0];
            $tekija = $row[1];
            $luokka = $row[2];
            $tyyppi = $row[3];
            $hinta = $row[4];
            // lisätään kirjan paino yhteispainoon
            $yhteispaino = $yhteispaino + $row[5];
            // lisätään kirjan hinta yhteishintaan
            $yhteissumma = $yhteissumma + $hinta;
            echo '<tr><td></td></tr>';
            echo '<tr><td>Nimi:   </td><td> '              . $nimi      . '</td></tr>';
            echo '<tr><td>Tekijä: </td><td> '              . $tekija    . '</td></tr>';
            echo '<tr><td>Luokka: </td><td> '              . $luokka    . '</td></tr>';
            echo '<tr><td>Tyyppi: </td><td> '              . $tyyppi    . '</td></tr>';
            echo '<tr><td>Hinta:  </td><td> '              . $hinta     . '</td></tr>';
            echo '<tr><td></td></tr>';
            echo '<tr><td></td></tr>';
        }
        
    }
    // lasketaan postikulut kirjojen yhteispainon perusteella
    $postikulukysely = "SELECT MAX(Postikulut.Postikulu) FROM keskustietokanta.Postikulut WHERE $yhteispaino >= Postikulut.Paino";
    $postikulut = pg_query($postikulukysely);
    while ($row2 = pg_fetch_row($postikulut)) {
        if ($yhteispaino <= 2000) {
            echo '<tr><td>Postikulut:   </td><td> '        . $row2[0]      . '</td></tr>';
            // lisätään postikulut loppusummaan ja tulostetaan tieto
            $yhteissumma = $yhteissumma + $row2[0];
            echo '<tr><td>Loppusumma:   </td><td> '        . $yhteissumma . '</td><td>€</td></tr>';
        }
        // jos yhteispaino ylittää 2000g, jaetaan tilaus useampaan erään
        else {
            echo '<h2>Tilauksen paino ylittää 2000g, joten se joudutaan jakamaan useampaan osaan. </h2>';
            // jaetaan tilausta osiin, kunnes kaikki osat ovat alle 2000g
            $i = 1;
            $paino = 0;
            $yli = 0;
            $kokonaishinta = 0;
            // käydään ostoskorin tuotteet yksitellen läpi
            foreach ($_SESSION['ostoskori'] as $value) {
                $tiedotkysely = "SELECT Teos.Nimi, Teos.Tekija, Teos.Luokka, Teos.Tyyppi, Nide.Hinta, Nide.Paino FROM keskustietokanta.Teos, keskustietokanta.Nide WHERE Teos.Id = Nide.Teos_id AND Nide.ID = $value";
                $tiedot = pg_query($tiedotkysely);
                while ($row = pg_fetch_row($tiedot)) {
                    // lisätään kirjan paino kokonaispainoon
                    $paino = $paino + $row[5];
                    
                    // jos edellisellä kierroksella kirja ei ole mahtunut tilaukseen, lisätään se uuteen tilaukseen
                    if ($yli != 0) {
                        $kokonaishinta = $kokonaishinta + $yli[4];
                        echo '<tr><td></td></tr>';
                        echo '<tr><td>Kirja tulee tilauksessa  </td><td> '         . $i           . '</td></tr>';
                        echo '<tr><td>Nimi:   </td><td> '              . $yli[0]      . '</td></tr>';
                        echo '<tr><td>Tekijä: </td><td> '              . $yli[1]      . '</td></tr>';
                        echo '<tr><td>Luokka: </td><td> '              . $yli[2]      . '</td></tr>';
                        echo '<tr><td>Tyyppi: </td><td> '              . $yli[3]      . '</td></tr>';
                        echo '<tr><td>Hinta:  </td><td> '              . $yli[4]      . '</td></tr>';
                        echo '<tr><td></td></tr>';
                        echo '<tr><td></td></tr>';
                        
                        $yli = 0;
                    }
                    
                    // jos tilauksen paino on sallituissa rajoissa, tulostetaan kierroksen kirjan tiedot,
                    // ja kerrotaan missä tilauksessa kirjat tulevat
                    if ($paino <= 2000) {
                        echo '<tr><td></td></tr>';
                        echo '<tr><td>Kirja tulee tilauksessa   </td><td> '         . $i           . '</td></tr>';
                        echo '<tr><td>Nimi:   </td><td> '              . $row[0]      . '</td></tr>';
                        echo '<tr><td>Tekijä: </td><td> '              . $row[1]      . '</td></tr>';
                        echo '<tr><td>Luokka: </td><td> '              . $row[2]      . '</td></tr>';
                        echo '<tr><td>Tyyppi: </td><td> '              . $row[3]      . '</td></tr>';
                        echo '<tr><td>Hinta:  </td><td> '              . $row[4]      . '</td></tr>';
                        echo '<tr><td></td></tr>';
                        echo '<tr><td></td></tr>';
                        $kokonaishinta = $kokonaishinta + $row[4];
                        $yli = 0;
                        
                    }
                    // jos tilauksen paino ei ole enää sallituissa rajoissa, ei lisätä kierroksen kirjaa
                    // enää tähän tilaukseen, vaan tulostetaan tilauksen postikulut ja kokonaishinta
                    else {
                        $postikulukysely2 = "SELECT MAX(Postikulut.Postikulu) FROM keskustietokanta.Postikulut WHERE $paino >= Postikulut.Paino";
                        $postikulut2 = pg_query($postikulukysely2);
                        while ($row4 = pg_fetch_row($postikulut2)) {
                            echo '<tr><td>Tilauksen  </td><td> '. $i . '</td><td> postikulut: </td><td>' . $row4[0] . '</td></tr>';
                            // lisätään postikulut loppusummaan ja tulostetaan tieto
                            $kokonaishinta = $kokonaishinta + $row4[0];
                            echo '<tr><td>Loppusumma:   </td><td> '        . $kokonaishinta . '</td><td>€</td></tr>';
                        }
                        $paino = 0;
                        $yli = $row;
                        $kokonaishinta = 0;
                        $i = $i + 1;
                    }
                }
                
            }
            // tulostetaan vielä lopuksi viimeisimmän tilauksen postikulut
            $postikulukysely2 = "SELECT MAX(Postikulut.Postikulu) FROM keskustietokanta.Postikulut WHERE $paino >= Postikulut.Paino";
            $postikulut2 = pg_query($postikulukysely2);
            while ($row4 = pg_fetch_row($postikulut2)) {
                echo '<tr><td>Tilauksen  </td><td> '. $i . '</td><td> postikulut: </td><td>' . $row4[0] . '</td></tr>';
                // lisätään postikulut loppusummaan ja tulostetaan tieto
                $kokonaishinta = $kokonaishinta + $row4[0];
                echo '<tr><td>Loppusumma:   </td><td> '        . $kokonaishinta . '</td><td>€</td></tr>';
            }
 
        }
    }
    echo '</table>';
}

// jos asiakas hyväksyy tilauksen, siirtyisi hän tässä vaiheessa pankin
// sivuille maksamaan, mutta sitä ei simuloida vaan merkataan kirjojen tila tietokantaan
// myydyksi ja siirrytään onnistunut_tilaus.php -sivulle
if (isset($_POST['vahvista'])) {
    // Lisätään tilaus tauluun tieto tilauksesta.
    $tilaus_id_kysely = "SELECT max(Tilaus_id) FROM keskustietokanta.Tilaus";
    $tilaus_id_kysely_tulos = pg_query($tilaus_id_kysely);
    $tilaus_id_rivi = pg_fetch_array($tilaus_id_kysely_tulos);
    if (!$tilaus_id_kysely_tulos) {
        $tilaus_id = 1;
    }
    else {
        $tilaus_id = intval($tilaus_id_rivi[0] + 1);
    }
    $osoite_kysely = "SELECT keskustietokanta.Asiakas.Osoite FROM keskustietokanta.Asiakas WHERE keskustietokanta.Asiakas.id = $asiakasid";
    $osoite_kysely_tulos = pg_query($osoite_kysely);
    $osoite_kysely_rivi = pg_fetch_array($osoite_kysely_tulos);
    if (!$osoite_kysely_tulos) {
        $osoite = NULL;
    }
    else {
        $osoite = $osoite_kysely_rivi[0];
    }
    $tilaus = "INSERT INTO keskustietokanta.Tilaus (Tilaus_id, Tila, Myyntipaivamaara, Toimituspaivamaara, Toimitusosoite, Toimitustapa) 
    VALUES ($tilaus_id, 'maksettu', CURRENT_DATE, NULL, '$osoite', 'paketti')";
    $tulos = pg_query($tilaus);
    foreach ($_SESSION['ostoskori'] as $value) {
        // etsitään nide, jolla on vastaava id,
        // ja muutetaan sen tila myydyksi
        $muutos = "UPDATE keskustietokanta.Nide SET tila = 'myyty' WHERE id = $value";
        $paivitys = pg_query($muutos);
        
        // tallennetaan tauluun myös myyntipäivämäärä
        $pvmmuutos = "UPDATE keskustietokanta.Nide SET Myyntipaivamaara = CURRENT_DATE WHERE id = $value";
        $pvmpaivitys = pg_query($pvmmuutos);

        // Tallennetaan tieto niteen ostosta ostanut tauluun.
        $divari_id_kysely = "SELECT keskustietokanta.Nide.Divari_ID FROM keskustietokanta.Nide WHERE id = $value";
        $divari_id_tulos = pg_query($divari_id_kysely);
        $divari_id_kysely_rivi = pg_fetch_array($divari_id_tulos);
        if (!$divari_id_tulos) {
        $divari_id = NULL;
        }
        else {
            $divari_id = intval($divari_id_kysely_rivi[0]);
        }
        $ostos = "INSERT INTO keskustietokanta.Ostanut (Id, Valikoima_Id, Divari_id, Tilaus_id)
                   VALUES ($asiakasid, $value, $divari_id, $tilaus_id)";
        $tulos = pg_query($ostos);
        if (($key = array_search($value, $_SESSION['ostoskori'])) !== false) {
        unset($_SESSION['ostoskori'][$key]);
        }
    }  
    header('Location: onnistunut_tilaus.php');
}

// jos asiakas valitsee hylätä tilauksen, vapautetaan kirjojen tila
// ja palataan takaisin haku-sivulle
elseif (isset($_POST['hylkaa'])) {
    foreach ($_SESSION['ostoskori'] as $value) {
        // etsitään nide, jolla on vastaava id,
        // ja muutetaan sen tila vapaaksi
        $muutos = "UPDATE keskustietokanta.Nide SET tila = 'vapaa' WHERE id = $value";
        $paivitys = pg_query($muutos);
    }     
    header('Location: haku.php');
}


// suljetaan tietokantayhteys

pg_close($yhteys);

?>

<html>
 <head>
  <title>Tilauksen tekeminen</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="ostamaan.php" method="post">

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
        <tr>
            <td></td>
            <td><input type="submit" name="vahvista" value="Vahvista tilaus"/></td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" name="hylkaa" value="Hylkää tilaus"/></td>
        </tr>
	</table>

	<br />

</body>
</html>