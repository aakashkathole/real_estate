import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PropertyPostScreen extends StatefulWidget {
  final String category;

  PropertyPostScreen({required this.category});

  @override
  _PropertyPostScreenState createState() => _PropertyPostScreenState();
}

class _PropertyPostScreenState extends State<PropertyPostScreen> {
  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;

  // Data for Andhra Pradesh and Telangana
  final Map<String, Map<String, List<String>>> locations = {
    "ANDHRA PRADESH": {
      "ANAKAPALLE": ["Anakapalle", "Atchutapuram", "Chodavaram", "Devarapalli", "Gajuwaka", "K.Kotapadu", "Madugula", "Nakkapalli", "Payakaraopeta", "Rambilli", "Rolugunta", "Sabbavaram", "Yelamanchili"],
      "ANNAMAYYA": ["B.Kothakota", "Chandragiri", "Chinnagottigallu", "Chittoor", "Chowdepalle", "Gangadhara Nellore", "Gudipala", "Irala", "K.V.B.Puram", "Kallur", "Kambhamvaripalle", "Karvetinagar", "Kuppam", "Nagari", "Nindra", "Peddapanjani", "Pileru", "Pulicherla", "Punganur", "Puthalapattu", "Renigunta", "Rompicherla", "Satyavedu", "Srikalahasti", "Thottambedu", "Vadamalapeta", "Vedurukuppam", "Vijayapuram", "Yadamari"],
      "ANANTHAPURAMU": ["Anantapur", "Dharmavaram", "Gooty", "Hindupur", "Kadiri", "Kalyandurg", "Madakasira", "Penukonda", "Puttaparthi", "Rayadurg", "Tadipatri", "Uravakonda"],
      "ALLURI SITHARAMA RAJU": ["Chintapalle", "G.K. Veedhi", "Paderu", "Araku Valley"],
      "BAPATLA": ["Bapatla", "Chirala", "Inkollu", "Karlapalem", "Nizampatnam", "Parchur", "Santhamaguluru", "Tsundur", "Vetapalem", "Yeddanapudi"],
      "CHITTOOR": ["Chittoor", "Pakala", "Puthalapattu", "Gudipala", "Palamaner", "Bangarupalem", "Gangadhara Nellore", "Kuppam", "Yadamari"],
      "EAST GODAVARI": ["Amalapuram", "Kakinada", "Mandapeta", "Peddapuram", "Rajanagaram", "Ravulapalem", "Samalkot", "Tuni"],
      "ELURU": ["Bhimadole", "Denduluru", "Eluru", "Gopalapuram", "Jangareddygudem", "Kamavarapukota", "Nallajerla", "Pedapadu", "Pedavegi"],
      "GUNTUR": ["Amaravati", "Bapatla", "Chilakaluripet", "Guntur", "Mangalagiri", "Narasaraopet", "Ponnur", "Repalle", "Tenali"],
      "KAKINADA": ["Kakinada", "Kothapeta", "Mandapeta", "Peddapuram", "Rajahmundry Rural", "Samalkot", "Tuni"],
      "KONASEEMA": ["Amalapuram", "Razole", "Mummidivaram", "Ramachandrapuram"],
      "KRISHNA": ["Gudivada", "Machilipatnam", "Nandivada", "Pedana", "Vijayawada", "Vuyyuru"],
      "KURNOOL": ["Adoni", "Alur", "Aspari", "Banaganapalle", "Chippagiri", "Dhone", "Gonegandla", "Gudur", "Kallur", "Kodumur", "Koilkuntla", "Kurnool", "Mahanandi", "Mantralayam", "Nandavaram", "Nandyal", "Orvakal", "Pattikonda", "Peddakadabur", "Peapally", "Srisailam", "Tuggali", "Uyyalawada", "Velgodu", "Yemmiganur"],
      "MANYAM": ["Kurupam", "Seethampeta", "Parvathipuram"],
      "NANDYAL": ["Atmakur", "Dhone", "Nandyal", "Banaganapalle"],
      "NELLORE": ["Allur", "Ananthasagaram", "Atmakur", "Bogole", "Buchireddipalem", "Chejerla", "Dagadarthi", "Dakkili", "Gudur", "Indukurpet", "Jaladanki", "Kaligiri", "Kavali", "Kodavalur", "Kovur", "Manubolu", "Muthukur", "Naidupet", "Nellore Rural", "Nellore Urban", "Ozili", "Podalakur", "Rapur", "Sullurpeta", "Thotapalligudur", "Udayagiri", "Vakadu", "Varikuntapadu", "Venkatachalam", "Vinjamur"],
      "PALNADU": ["Dachepalli", "Gurazala", "Macherla", "Narasaraopet", "Pedakurapadu", "Vinukonda"],
      "PARVATHIPURAM": ["Parvathipuram", "Salur", "Kurupam"],
      "PRAKASAM": ["Chirala", "Darsi", "Giddalur", "Kanigiri", "Kandukur", "Markapur", "Ongole", "Podili", "Yerragondapalem"],
      "SRI SATYASAI": ["Dharmavaram", "Kadiri", "Puttaparthi", "Penukonda", "Madakasira", "Hindupur"],
      "SRIKAKULAM": ["Amadalavalasa", "Etcherla", "Gara", "Ichchapuram", "Jalumuru", "Narasannapeta", "Palasa", "Tekkali", "Sompeta"],
      "TIRUPATI": ["Tirupati", "Srikalahasti", "Renigunta", "Puttur"],
      "VISAKHAPATNAM": ["Anandapuram", "Bheemunipatnam", "Chodavaram", "Gajuwaka", "Gopalapatnam", "Malkapuram", "Narsipatnam", "Pendurthi", "Parawada", "Visakhapatnam Urban"],
      "WEST GODAVARI": ["Achanta", "Attili", "Bhimavaram", "Denduluru", "Elamanchili", "Kovvur", "Narasapuram", "Palakollu", "Tanuku", "Tadepalligudem"],
      "YSR KADAPA": ["Badvel", "Jammalamadugu", "Kadapa", "Kamalapuram", "Mydukur", "Proddatur", "Pulivendula", "Rajampet", "Rayachoti", "Vempalle"],
      "VIZIANAGARAM": ["Bobbili", "Cheepurupalli", "Gajapathinagaram", "Parvathipuram", "Salur", "S.Kota", "Vizianagaram"]
    },
      "TELANGANA": {
        "ADILABAD": ["Adilabad", "Asifabad", "Bazarhathnoor", "Bejjur", "Bellampalle", "Bela", "Bhainsa", "Boath", "Dahegaon", "Ichoda", "Indravelli", "Jainad", "Jannaram", "Kagaznagar", "Kerameri", "Kouthala", "Kuntala", "Lingapur", "Luxettipet", "Mandamarri", "Mudhole", "Narnoor", "Nennel", "Neradigonda", "Rebbana", "Sirpur (T)", "Talamadugu", "Tamsi", "Tanoor", "Tiryani", "Utnoor", "Wankidi"],
        "BHADRADRI KOTHAGUDEM": ["Aswaraopeta", "Aswapuram", "Ashwaraopet", "Burgampahad", "Chandrugonda", "Chunchupalle", "Dammapeta", "Dummugudem", "Garla", "Gundala", "Julurpad", "Kothagudem", "Kukunoor", "Manuguru", "Mukkalapalli", "Palwancha", "Pinapaka", "Sathupalli", "Tallada", "Tekulapalli", "Velerupadu", "Yellandu"],
        "HYDERABAD": ["Amberpet", "Ameerpet", "Asifnagar", "Bahadurpura", "Bandlaguda", "Charminar", "Golconda", "Himayathnagar", "Hyderabad", "Khairatabad", "Marredpally", "Musheerabad", "Nampally", "Saidabad", "Secunderabad", "Shaikpet", "Tirumalagiri"],
        "JAGTIAL": ["Bejjanki", "Dharmapuri", "Elkathurthy", "Gangadhara", "Ibrahimpatnam", "Jagtial", "Kathlapur", "Kodimial", "Korutla", "Mallial", "Medipalli", "Metpalli", "Pegadapalli", "Raikal", "Sarangapur", "Velgatoor"],
        "JANGAON": ["Chilpur", "Devaruppula", "Ghanpur (Station)", "Jangaon", "Kodakandla", "Lingala Ghanpur", "Narmetta", "Palakurthi", "Raghunathpalle", "Zaffergadh"],
        "JAYASHANKAR BHUPALPALLY": ["Bhupalpally", "Chinnakodepaka", "Eturnagaram", "Ghanpur", "Gudur", "Kannaigudem", "Mangapet", "Mulug", "Narsimhulapet", "Regonda", "Tadvai", "Venkatapur"],
        "JOGULAMBA GADWAL": ["Alampur", "Dharoor", "Gadwal", "Ghattu", "Ieeja", "Itikyal", "Kothakota", "Maganoor", "Maldakal", "Manopad", "Rajoli", "Waddepalle"],
        "KAMAREDDY": ["Banswada", "Bhiknur", "Bichkunda", "Domakonda", "Kamareddy", "Lingampet", "Machareddy", "Nagireddipet", "Peddakodapgal", "Ramareddy", "Sadashivanagar", "Yellareddy"],
        "KARIMNAGAR": ["Boinpalle", "Choppadandi", "Ellanthakunta", "Gangadhara", "Huzurabad", "Jammikunta", "Karimnagar", "Kathlapur", "Kothapalli", "Mahadevpur", "Manakondur", "Mustabad", "Ramadugu", "Saidapur", "Thimmapur", "Veenavanka"],
        "KHAMMAM": ["Bonakal", "Chandrugonda", "Chintakani", "Enkoor", "Khammam", "Kamepalle", "Konijerla", "Kusumanchi", "Madhira", "Mudigonda", "Nelakondapalle", "Penuballi", "Raghunathapalem", "Sathupalle", "Tallada", "Thirumalayapalem", "Vemsoor", "Wyra", "Yerrupalem"],
        "MAHABUBABAD": ["Chennaraopet", "Dornakal", "Ghanpur", "Gudur", "Kesamudram", "Kuravi", "Mahabubabad", "Maripeda", "Narsimhulapet", "Nekkonda", "Nellikudur", "Thorrur"],
        "MAHABUBNAGAR": ["Addakal", "Amangal", "Balanagar", "Bhoothpur", "C.C.Kunta", "Devarakadra", "Doulathabad", "Farooqnagar", "Gopalpeta", "Hanwada", "Jadcherla", "Keshampet", "Kodair", "Kondurg", "Kothur", "Maddur", "Maganoor", "Mahabubnagar", "Maldakal", "Makthal", "Midjil", "Nawabpet", "Pedda Kothapalle", "Rajapur", "Shadnagar", "Thimmajipet", "Vangoor", "Wanaparthy"],
        "MEDAK": ["Alladurg", "Chegunta", "Dubbak", "Gajwel", "Hathnoora", "Jinnaram", "Kohir", "Kondapak", "Kulcharam", "Manoor", "Medak", "Narsapur", "Nyalkal", "Papannapet", "Ramayampet", "Sangareddy", "Shankarampet (A)", "Shankarampet (R)", "Siddipet", "Tekmal", "Toopran", "Wargal", "Yeldurthy", "Zahirabad"],
        "MEDCHAL-MALKAJGIRI": ["Alwal", "Balanagar", "Dundigal", "Ghatkesar", "Hayathnagar", "Keesara", "Kukatpalle", "Malkajgiri", "Medchal", "Quthbullapur", "Shamirpet", "Uppal"],
        "NAGARKURNOOL": ["Achampet", "Amrabad", "Bijinepalle", "Chinnachintakunta", "Kollapur", "Lingal", "Nagarkurnool", "Peddakothapalle", "Tadoor", "Telkapalle", "Thimmajipet", "Uppununthala", "Vangoor", "Wanaparthy"],
        "NALGONDA": ["Bhongir", "Bibinagar", "Choutuppal", "Devarakonda", "Gurrampode", "Kanagal", "Kattangur", "Kodad", "Mothkur", "Munugode", "Nakrekal", "Nalgonda", "Nampalle", "Narayanapur", "Nidamanur", "Peddavoora", "Suryapet", "Thipparthy", "Tirumalagiri", "Yadagirigutta"],
        "NIRMAL": ["Bhainsa", "Dilawarpur", "Kadam", "Kubeer", "Laxmanchanda", "Mamda", "Narsapur", "Nirmal", "Sarangapur", "Soan", "Tanoor"],
        "NIZAMABAD": ["Armoor", "Balkonda", "Bheemgal", "Bodhan", "Dharpalle", "Jakranpalle", "Kamareddy", "Kotgiri", "Mortad", "Nandipet", "Navipet", "Nizamabad", "Yedapalle"],
        "PEDDAPALLI": ["Dharmaram", "Julapalle", "Kamanpur", "Manthani", "Peddapalli", "Ramagundam", "Srirampur", "Sultanabad", "Yellareddipet"],
        "RAJANNA SIRCILLA": ["Boinpalle", "Chandurthi", "Konaraopeta", "Mustabad", "Sircilla", "Vemulawada", "Yellareddypet"],
        "RANGAREDDY": ["Balanagar", "Chevella", "Gandipet", "Ibrahimpatnam", "Kandukur", "Maheshwaram", "Marpalle", "Medchal", "Moinabad", "Pargi", "Quthbullapur", "Rajendranagar", "Rangareddy", "Serilingampally", "Shabad", "Shamshabad", "Tandur", "Uppal", "Vikarabad"],
        "SANGAREDDY": ["Andole", "Jinnaram", "Kohir", "Kondapak", "Kulcharam", "Manoor", "Narsapur", "Nyalkal", "Papannapet", "Ramayampet", "Sadasivpet", "Sangareddy", "Siddipet", "Tekmal", "Toopran", "Wargal", "Zahirabad"],
        "SIDDIPET": ["Chinnakodapaka", "Doulathabad", "Gajwel", "Husnabad", "Jagadevpur", "Kondapak", "Kulcharam", "Nangnoor", "Raikode", "Siddipet", "Thoguta", "Wargal"],
        "SURYAPET": ["Atmakur", "Chivvemla", "Huzurnagar", "Kodad", "Mothey", "Mothkur", "Nadigudem", "Nalgonda", "Nampalle", "Penpahad", "Sali Gouraram", "Suryapet", "Thipparthy", "Tirumalagiri", "Vemulapalle"],
        "VIKARABAD": ["Bantwaram", "Dharur", "Doma", "Kodangal", "Kulkacharla", "Marpalle", "Mominpet", "Nawabpet", "Pargi", "Peddemul", "Pudur", "Tandur", "Vikarabad", "Yelal"],
        "WANAPARTHY": ["Amarchinta", "Atmakur", "Ghanpur", "Kothakota", "Madgul", "Pebbair", "Peddamandadi", "Poodur", "Raghunathpalle", "Srirangapur", "Wanaparthy"],
        "WARANGAL URBAN": ["Hanamkonda", "Hasanparthy", "Kazipet", "Madikonda", "Mangapet", "Narsampet", "Parvathagiri", "Regonda", "Sangam", "Shayampet", "Warangal", "Zaffergadh"],
        "WARANGAL RURAL": ["Atmakur", "Bhupalpalle", "Chityal", "Dornakal", "Eturnagaram", "Ghanpur", "Jangaon", "Kuravi", "Mahabubabad", "Mangapet", "Maripeda", "Mulug", "Nallabelly", "Narsampet", "Parkal", "Regonda", "Thorrur", "Venkatapur", "Warangal Rural"],
        "YADADRI BHUVANAGIRI": ["Alair", "Atmakur", "Bommalaramaram", "Bhuvanagiri", "Choutuppal", "Gundala", "Kattangur", "Mothkur", "Nalgonda", "Nakrekal", "Narketpalle", "Peddavoora", "Ramannapeta", "Valigonda", "Yadagirigutta"]
      }
  };

  // Get list of states
  List<String> get states => locations.keys.toList();

  // Get list of districts based on selected state
  List<String> get districts => selectedState != null ? locations[selectedState]!.keys.toList() : [];

  // Get list of talukas/towns based on selected district
  List<String> get talukas => selectedDistrict != null && selectedState != null
      ? locations[selectedState]![selectedDistrict]!
      : [];

  String selectedLookingFor = "";
  String selectedPropertyKind = "";
  String selectedPropertyType = "";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLookingFor = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Add Basic Details"),
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildSectionTitle("You're looking to?"),
            _buildChoiceChips(["Sell", "Rent", "Paying Guest"], selectedLookingFor, (value) {
              setState(() => selectedLookingFor = value);
            }),

            _buildSectionTitle("What kind of property?"),
            _buildChoiceChips(["Residential", "Commercial"], selectedPropertyKind, (value) {
              setState(() {
                selectedPropertyKind = value;
                selectedPropertyType = ""; // Reset property type when kind changes
              });
            }),

            _buildSectionTitle("Select Property Type"),
            _buildChoiceChips([
              "Apartment",
              "Independent House | Villa",
              "Independent | Builder Floor",
              "Serviced Apartment",
              "1 RK",
              "1 BHK",
              "Land | Plot",
              "Farm Land",
              "Office Space",
              "Retail Shop",
              "Warehouse",
              "Co-working Space",
              "Industrial Land",
            ], selectedPropertyType, (value) {
              setState(() => selectedPropertyType = value);
            }),

            _buildSectionTitle("Your contact details"),
            _buildTextField("Name", nameController),
            SizedBox(height: 10),
            _buildTextField("Contact number", contactController),
            SizedBox(height: 10),
            _buildTextField("Location", locationController),
            SizedBox(height: 10),
            _buildTextField("Price", priceController) ,

            _buildSectionTitle("Select State"),
            _buildDropdown("State", states, selectedState, (value) {
              setState(() {
                selectedState = value;
                selectedDistrict = null; // Reset district when state changes
                selectedTaluka = null; // Reset taluka when state changes
              });
            }),

            if (selectedState != null) ...[
        _buildSectionTitle("Select District"),
    _buildDropdown("District", districts, selectedDistrict, (value) {
    setState(() {
    selectedDistrict = value;
    selectedTaluka = null; // Reset taluka when district changes
    });
    }),
    ],

    if (selectedDistrict != null) ...[
    _buildSectionTitle("Select Taluka/Town"),
    _buildDropdown("Taluka/Town", talukas, selectedTaluka, (value) {
    setState(() => selectedTaluka = value);
    }),
    ],

    SizedBox(height: 30),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _submitForm,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green, // Green background
    foregroundColor: Colors.white, // White text
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    ),
    child: Text("Submit", style: TextStyle(fontSize: 18)),
    ),
    ),
                ],
    ),
    ),
    );
  }

  Widget _buildDropdown(String hint, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(hint),
      isExpanded: true,
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.green),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChoiceChips(List<String> options, String selected, Function(String) onSelected) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option, style: TextStyle(
            color: selected == option ? Colors.white : Colors.black, // White text if selected, black otherwise
          )),
          selected: selected == option,
          selectedColor: Colors.green, // Green when selected
          backgroundColor: Colors.grey[200], // Light gray background when not selected
          onSelected: (selected) {
            if (selected) onSelected(option);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (nameController.text.isEmpty || contactController.text.isEmpty || locationController.text.isEmpty || priceController.text.isEmpty
        || selectedState == null || selectedDistrict == null || selectedTaluka == null
        || selectedLookingFor.isEmpty || selectedPropertyKind.isEmpty || selectedPropertyType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all details")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    String userEmail = user.email!.toLowerCase();
    await FirebaseFirestore.instance.collection("Posts_for_approval").add({
      "email": userEmail,
      "name": nameController.text,
      "contact": contactController.text,
      "location": locationController.text,
      "state": selectedState,
      "district": selectedDistrict,
      "taluka": selectedTaluka,
      "lookingFor": selectedLookingFor,
      "propertyKind": selectedPropertyKind,
      "propertyType": selectedPropertyType,
      "propertyPrice": priceController.text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Form Submitted Successfully!")),
    );

    // Clear input fields after submission
    nameController.clear();
    contactController.clear();
    locationController.clear();
    priceController.clear();
    setState(() {
      selectedState = null;
      selectedDistrict = null;
      selectedTaluka = null;
      selectedLookingFor = "";
      selectedPropertyKind = "";
      selectedPropertyType = "";
    });
  }
}