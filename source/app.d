import std;
import arsd.minigui;
import fixedpoint.fixed;

void setEnabled(Window w, bool e) {
    import core.sys.windows.windows;
    if(w.win.impl.hwnd)
    {
        EnableWindow(w.win.impl.hwnd, e);
    }

    foreach(child; w.children)
            child.enabled = e;
}

void correctScale(StaticLayout l)
{   
    /*foreach(child; l.children)
    {
        child.x = child.scaleWithDpi(child.x);
        child.y = child.scaleWithDpi(child.y);
        child.width = child.scaleWithDpi(child.width);
        child.height = child.scaleWithDpi(child.height);
    }*/
}


class FishingWindow : MainWindow
{
    private FishDatabase _fishDatabase;
    private ListWidget _listBox;
    private LineEdit _editPieces;
    private LineEdit _editWeight;
    private TextLabel _lblPiecesSum;
    private TextLabel _lblWeightSum;
    private string _section;
    private string _species;

    Color color;
    class Style : Widget.Style {
        override WidgetBackground background() { return WidgetBackground(color); }
    }
    mixin OverrideStyle!Style;

    this()
    {
        this.color = Color.teal;
        super("Fangliste", scaleWithDpi(800), scaleWithDpi(450));

        _section = "1";
        _fishDatabase = new FishDatabase(buildPath(dirName(thisExePath), "database.json"));

        auto staticLayout = new StaticLayout(this);

        _listBox = new ListWidget(staticLayout);
        with(_listBox)
        {
            x = 24; y = 32; width = 193; height = 200;
        }
        _listBox.addEventListener((ChangeEvent!void ce) { 
            auto selectedIdx = _listBox.getSelection();
            if (selectedIdx > -1)
                onSpeciesSelected(_listBox.options[selectedIdx].label);
            else
                onSpeciesSelected("");
        });

        // Abschnitt
        auto fieldSet = new Fieldset("Abschnitt", staticLayout);
        with(fieldSet)
        {
            x = 272; y = 32; width = 140; height = 200;
        }

        auto rbAbschnitt1 = new Radiobox("1", fieldSet);
        with (rbAbschnitt1)
        {
            x = 10; y = 10; width = 30; height = 20;
        }
        rbAbschnitt1.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("1");
        });

        auto rbAbschnitt2 = new Radiobox("2", fieldSet);
        with (rbAbschnitt2)
        {
            x = 10; y = 30; width = 30; height = 20;
        }
        rbAbschnitt2.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("2");
        });

        auto rbAbschnitt3 = new Radiobox("3", fieldSet);
        with (rbAbschnitt3)
        {
            x = 10; y = 50; width = 30; height = 20;
        }
        rbAbschnitt3.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("3");
        });

        auto rbAbschnitt4 = new Radiobox("4", fieldSet);
        with (rbAbschnitt4)
        {
            x = 10; y = 80; width = 30; height = 20;
        }
        rbAbschnitt4.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("4");
        });

        auto rbAbschnitt5 = new Radiobox("5", fieldSet);
        with (rbAbschnitt5)
        {
            x = 10; y = 110; width = 30; height = 20;
        }
        rbAbschnitt5.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("5");
        });

        auto rbAbschnitt6 = new Radiobox("6", fieldSet);
        with (rbAbschnitt6)
        {
            x = 10; y = 140; width = 30; height = 20;
        }
        rbAbschnitt6.addEventListener((ChangeEvent!bool ce) {
            if (ce.value == true) onSectionSelected("6");
        });

        // Insgesamt
        with (new TextLabel("Insgesamt", TextAlignment.Left, staticLayout) )
        {
            x = 24; y = 256; width = 120; height = 20;
        }

        with (new TextLabel("St??ck", TextAlignment.Left, staticLayout))
        {
            x = 40; y = 296; width = 73; height = 20;
        }

        with (new TextLabel("Kilogramm", TextAlignment.Left, staticLayout))
        {
            x = 40; y = 320; width = 73; height = 20;
        }

        _lblPiecesSum = new TextLabel("0", TextAlignment.Left, staticLayout);
        with (_lblPiecesSum)
        {
            x = 120; y = 296; width = 50; height = 20;
        }

        _lblWeightSum = new TextLabel("0", TextAlignment.Left, staticLayout);
        with (_lblWeightSum)
        {
            x = 120; y = 320; width = 50; height = 20;
        }

        // Eingabe
        with (new TextLabel("Eingabe", TextAlignment.Left, staticLayout))
        {
            x = 272; y = 256; width = 120; height = 20;
        }

        with (new TextLabel("St??ck", TextAlignment.Left, staticLayout))
        {
            x = 272; y = 296; width = 50; height = 20;
        }

        _editPieces = new LineEdit(staticLayout);
        with (_editPieces)
        {
            x = 360; y = 288; width = 57; height = 25;
        }
        _editPieces.addEventListener(delegate(BlurEvent ce) { 
            this.onInput();
        });

        with (new TextLabel("Kilogramm", TextAlignment.Left, staticLayout))
        {
            x = 272; y = 320; width = 80; height = 20;
        }

        _editWeight = new LineEdit(staticLayout);
        with (_editWeight)
        {
            x = 360; y = 312; width = 57; height = 25;
        }
        _editWeight.addEventListener(delegate(BlurEvent ce) { 
            this.onInput();
        });

        // Buttons
        auto btnPrint = new Button("Drucken", staticLayout);
        with (btnPrint)
        {
            x = 480; y = 32; width = 140; height = 22;
        }
        btnPrint.addWhenTriggered(&print);

        auto btnNewFishSpecies = new Button("Neue Fischart", staticLayout);
        with (btnNewFishSpecies)
        {
            x = 480; y = 96; width = 140; height = 22;
        }
        btnNewFishSpecies.addWhenTriggered(&addFishSpecies);

        auto btnClose = new Button("Beenden", staticLayout);
        with (btnClose)
        {
            x = 480; y = 128; width = 140; height = 22;
        }
        btnClose.addWhenTriggered(&close);

        auto btnDeleteDb= new Button("Datenbank l??schen", staticLayout);
        with (btnDeleteDb)
        {
            x = 480; y = 160; width = 140; height = 22;
        }
        btnDeleteDb.addWhenTriggered(&deleteDatabase);

        auto btnDeleteFishSpecies= new Button("Fischart l??schen", staticLayout);
        with (btnDeleteFishSpecies)
        {
            x = 480; y = 192; width = 140; height = 22;
        }
        btnDeleteFishSpecies.addWhenTriggered(&deleteFishSpecies);

        _refreshListBox();
        staticLayout.correctScale();
    }

    private void _refreshListBox(string selectSpecies = "")
    {
        _listBox.clear();
        foreach(fishSpecies; _fishDatabase.getSpecies)
        {
            _listBox.addOption(fishSpecies);
            if (selectSpecies == fishSpecies)
            {
                _listBox.setSelection(cast(int) _listBox.options.length - 1);
            }   
        }

        if (selectSpecies == "" && _listBox.options.length > 0)
        {
            _listBox.setSelection(0);
        }   
    }

    void onSectionSelected(string section)
    {
        _section = section;
        if (_species != "")
            showInputValues(_section, _species);
    }

    void onSpeciesSelected(string species)
    {
        _species = species;
        if (_species != "")
        {
            showInputValues(_section, _species);
            refreshSumValues();
        }   
    }

    void showInputValues(string section, string species)
    {
        auto inputValues = _fishDatabase.getSpeciesValues(section, species);
        _editPieces.content = inputValues.pieces.text;
        _editWeight.content = inputValues.weight.toString;
    }

    void deleteFishSpecies()
    {
        auto selectedIdx = _listBox.getSelection();
        if (selectedIdx > -1)
        {
            string fishSpecies = _listBox.options[selectedIdx].label;
            _fishDatabase.deleteSpecies(fishSpecies);
            _species = "";
            _lblPiecesSum.label = "0";
            _lblWeightSum.label = "0.00";
            _editPieces.content = "0";
            _editWeight.content = "0.00";
            _refreshListBox();
        }
    }

    void addFishSpecies()
    {
        struct NeueFischart 
        {
            string FischartEingeben;
        }

        setEnabled(this, false);

        dialog((NeueFischart ns) {
            string speciesName = ns.FischartEingeben.strip;
            setEnabled(this, true);
            if (speciesName == "")
            {
                messageBox("Info", "Fischart ist leer");
            }
            else if (_fishDatabase.speciesExists(speciesName))
            {
                messageBox("Info", "Fischart existiert bereits");
            }
            else
            {
                _fishDatabase.addSpecies(speciesName);
                _refreshListBox(speciesName);
            }
        }, () {
            setEnabled(this, true);
        });
    }

    void deleteDatabase()
    {
        _fishDatabase.reinitDatabase();
        _refreshListBox();
        _lblPiecesSum.label = "0";
        _lblWeightSum.label = "0.00";
        _editPieces.content = "0";
        _editWeight.content = "0.00";
    }

    void onInput()
    {
        if (_species != "" && _section != "")
        {
            try
            {
                int i = _editPieces.content.to!int;
            }
            catch(Exception e)
            {
                messageBox("Error", "St??ck ist keine g??ltige Zahl");
                _editPieces.content = "0";
            }
            
            string weight = _editWeight.content.replace(`,`, `.`);
            
            try
            {
               auto f = Fixed!(2)(weight);
            }
            catch(Exception e)
            {
                messageBox("Error", "Gewicht ist keine g??ltige Zahl");
                weight = "0.00";
                _editWeight.content = weight;
            }
            
            _fishDatabase.setSpeciesSectionValues(_section, _species, SpeciesValues(_editPieces.content.to!int, Fixed!(2)(weight)));
            refreshSumValues();
        }
    }

    void refreshSumValues()
    {
        if (_species != "")
        {
            auto sumValues = _fishDatabase.getSpeciesValuesSum(_species);
            _lblPiecesSum.label = sumValues.pieces.text;
            _lblWeightSum.label = sumValues.weight.toString();
        }
    }

    void print()
    {
        string htmlFilePath = buildPath(dirName(thisExePath), "print.html");
        toFile(_fishDatabase.asHtmlTable, htmlFilePath);
        browse(htmlFilePath);
    }
}

void main() 
{
    auto window = new FishingWindow();
    window.loop();
}

struct SpeciesValues
{
    int pieces;
    Fixed!2 weight;
}

class FishDatabase
{
    private string _filePath;
    private JSONValue _jsDatabase;

    this(string filePath)
    {
        _filePath = filePath;
        if (_filePath.exists)
            _jsDatabase = parseJSON(readText(_filePath));
        else
            initDatabase();
    }

    void saveDatabase()
    {
        _jsDatabase.toPrettyString.toFile(_filePath);
    }

    void initDatabase()
    {
        _jsDatabase = JSONValue(["sections": JSONValue([
                "1": JSONValue(string[string].init),
                "2": JSONValue(string[string].init),
                "3": JSONValue(string[string].init),
                "4": JSONValue(string[string].init),
                "5": JSONValue(string[string].init),
                "6": JSONValue(string[string].init) ])]);
        saveDatabase(); 
    }
    
    void reinitDatabase()
    {
        foreach(species; getSpecies())
        {
            foreach(n; 1..7)
            {
                _jsDatabase["sections"].object[n.text].object[species] = JSONValue(["pieces" : JSONValue("0"), "weight": JSONValue("0.00")]);
            }
        }
    
    }

    string[] getSpecies()
    {
        return _jsDatabase["sections"].object["1"].object.keys.sort.array;
    }

    bool speciesExists(string species)
    {
        return ((species.strip in _jsDatabase["sections"].object["1"].object) !is null);
    }

    SpeciesValues getSpeciesValues(string section, string species)
    {
        JSONValue js = _jsDatabase["sections"].object[section].object[species.strip];
        return SpeciesValues(js["pieces"].str.to!int, Fixed!2(js["weight"].str));
    }

    SpeciesValues getSpeciesValuesSum(string species)
    {
        SpeciesValues result; 
        foreach(n; 1..7)
        {
            result.pieces += _jsDatabase["sections"].object[n.text].object[species.strip].object["pieces"].str.to!int;
            result.weight += Fixed!2(_jsDatabase["sections"].object[n.text].object[species.strip].object["weight"].str);
        }
        
        return result;
    }

    void setSpeciesSectionValues(string section, string species, SpeciesValues speciesValues)
    {
        _jsDatabase["sections"].object[section].object[species.strip] = JSONValue(["pieces" : JSONValue(speciesValues.pieces.text), "weight": JSONValue(speciesValues.weight.toString)]);
        saveDatabase(); 
    }

    void addSpecies(string species)
    {
        foreach(n; 1..7) _jsDatabase["sections"].object[n.text].object[species.strip] = JSONValue(["pieces" : JSONValue("0"), "weight": JSONValue("0.00")]);
        saveDatabase(); 
    }

    void deleteSpecies(string species)
    {
        foreach(n; 1..7) _jsDatabase["sections"].object[n.text].object.remove(species.strip);
        saveDatabase(); 
    }

    string asHtmlTable()
    {
        string result = `<html><head>
            <style>
            table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            text-align: center;
            }
            th, td {
            padding: 15px;
            }
            </style>
            </head>
            <body><table border="1"><tr>
            <td>Fischart</td>
            <td>Abschnitt 1 St&uuml;ck</td>
            <td>kg</td>
            <td>Abschnitt 2 St&uuml;ck</td>
            <td>kg</td>
            <td>Abschnitt 3 St&uuml;ck</td>
            <td>kg</td>
            <td>Abschnitt 4 St&uuml;ck</td>
            <td>kg</td>
            <td>Abschnitt 5 St&uuml;ck</td>
            <td>kg</td>
            <td>Abschnitt 6 St&uuml;ck</td>
            <td>kg</td>
            <td>Gesamt St&uuml;ck</td>
            <td>Gesamt kg</td>
            </tr>`;

        foreach(species; getSpecies())
        {
            result ~= `<tr><td>` ~ species ~ `</td>`;
            foreach(n; 1..7)
            {
                auto speciesValues = getSpeciesValues(n.text, species);
                result ~= `<td>` ~ speciesValues.pieces.text ~ `</td>` ~ `<td>` ~ speciesValues.weight.toString ~ `</td>`;
            }

            auto speciesValuesSum = getSpeciesValuesSum(species);
            result ~= `<td>` ~ speciesValuesSum.pieces.text ~ `</td>` ~ `<td>` ~ speciesValuesSum.weight.toString ~ `</td>`;
        }

        result ~= `</table></body></html>`;
        return result;
    }
}

