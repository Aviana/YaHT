local AceLocale = AceLibrary("AceLocale-2.2"):new("YaHT");

AceLocale:RegisterTranslations("deDE", function() 
    return
	{
		-- Command params
		["Lock"] = "Sperren",
		["Lock Timer and Castbar into position"] = "Sperre Wirkungsleiste und Messleiste",
		["Castbar Options"] = "Wirkungsleistenoptionen",
		["Aimed Shot in castbar"] = "Gezielter Schuss in der Wirkungsleiste",
		["Show 'Aimed Shot' in the castbar"] = "Zeige 'Gezielter Schuss' in der Wirkungsleiste",
		["Multi-Shot in castbar"] = "Mehrfachschuss in der Wirkungsleiste",
		["Show 'Multi-Shot' in the castbar"] = "Zeige 'Mehrfachschuss' in der Wirkungsleiste",
		["Timer Color"] = "Messleistenfarbe",
		["Set the color of the timer between shots"] = "Setze die Farbe der Messleiste zwischen Sch�ssen",
		["Draw Color"] = "Ladebalkenfarbe",
		["Set the color of the bar while the weapon charges"] = "Setze die Farbe der Leiste w�hrend die Waffe l�d",
		["Border Color"] = "Randfarbe",
		["Set the color of the border"] = "Setze die Farbe des Randes",
		["Tranq options"] = "'Einlullender Schuss' Optionen",
		["Tranq announce"] = "'Einlullender Schuss' Ansage",
		["Enable Tranquilizing Shot announce"] = "Melde 'Einlullender Schuss' an einen Kanal",
		["Tranq fail announce"] = "'Einlullender Schuss' Verfehl-Ansage",
		["Enable failed Tranquilizing Shot announce"] = "Melde 'Einlullender Schuss verfehlt' an einen Kanal",
		["<Message>"] = "<Nachricht>",
		["Channel"] = "Chatkanal",
		["Channel in which to announce"] = "Kanal in dem angesagt wird.",
		["<channelname>"] = "<Kanalname>",
		["Tranq Message"] = "'Einlullender Schuss' Nachricht",
		["What to send to the channel"] = "Was an den Kanal \195\188bermittelt wird.",
		["Use plain text and substitute the targets name with %t"] = "Benutze Klartext und verwende %t um den namen des Ziels zu setzen",
		["Tranq fail Message"] = "Einlull Verfehl-Nachricht",
		["What to send to the channel when tranq failed"] = "Was an den Kanal \195\188bermittelt wird wenn fehlgeschlagen",
		["Reset Settings"] = "Einstellungen zur�cksetzen",
		
		["Timer options"] = "Messleistenoptionen",
		["Height"] = "H�he",
		["Width"] = "Breite",
		["Border Thickness"] = "Randbreite",
		["Alpha"] = "Alpha",
		["Movement Alpha"] = "Bewegungsalpha",
		["Alpha during player movent"] = "Alpha w�hrend der Spielebewegung",
		["Bar Texture"] = "Bar Textur",
		["<texturename>"] = "<texturname>",
		["L2R Growth"] = "L2R Growth"
		["Toggle between centered growth and left to right growth"] = "Umschalten zwischen Wachsen von der Mitte nach au�en zu Links nach Rechts",

		
		["Aimed Shot"] = "Gezielter Schuss",
		["Multi-Shot"] = "Mehrfachschuss",
		["Serpent Sting"] = "Schlangenbiss",
		["Arcane Shot"] = "Arkaner Schuss",
		["Concussive Shot"] = "Ersch\195\188tternder Schuss",
		["Distracting Shot"] = "Ablenkender Schuss",
		["Scatter Shot"] = "Streuschuss",
		["Scorpid Sting"] = "Skorpidstich",
		["Viper Sting"] = "Vipernbiss",
		["Tranquilizing Shot"] = "Einlullender Schuss",
		
		["Loaded. The hunt begins!"] = "Geladen. Die Jagt beginnt!",
		["Locked."] = "Verriegelt.",
		["Unlocked."] = "Entriegelt.",
		["Do you really want to reset to default for your current profile?"] = "M�chtest du wirklich dein momentanes Profil zur�cksetzen?",
		["OK"] = "OK",
		["Cancel"] = "Abbrechen",
		["Current profile has been reset."] = "Das momentane Profil wurde zur�ckgesetzt.",
		
		["YaHT_MISS"] = "Einlullender Schuss hat .+ verfehlt",
		["YaHT_FAILEDMSG"] = "YaHT: Einlullender Schuss fehlgeschlagen!",
		["YaHT_TRANQMSG"] = "YaHT: Einlullender Schuss auf %t",
	}
end)
