// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {

    // --- LES 4 ETATS DU MEDICAMENT ---
    enum State { 
        CREE_PAR_GROSSISTE,   // 0
        VALIDE_PAR_HOPITAL,   // 1 (Nouvelle étape ajoutée)
        EN_STOCK_PHARMACIE,   // 2
        ADMINISTRE            // 3
    }

    struct LotMedicament {
        uint id;
        string nom;
        State etat;
        address auteurDerniereAction;
        uint dateAction;
    }

    mapping(uint => LotMedicament) public lots;

    // --- EVENEMENTS ---
    event NouveauLot(uint id, string nom);
    event ValidationHopital(uint id, address hopital);
    event ReceptionPharmacie(uint id, address pharmacien);
    event Administration(uint id, address infirmier);

    // --- ETAPE 1 : Le Grossiste crée le lot ---
    function creerLot(uint _id, string memory _nom) public {
        require(lots[_id].id == 0, "Ce lot existe deja");
        
        lots[_id] = LotMedicament({
            id: _id,
            nom: _nom,
            etat: State.CREE_PAR_GROSSISTE,
            auteurDerniereAction: msg.sender,
            dateAction: block.timestamp
        });

        emit NouveauLot(_id, _nom);
    }

    // --- ETAPE 2 : L'Hôpital valide la réception (Le Quai de déchargement) ---
    function validerReceptionHopital(uint _id) public {
        LotMedicament storage lot = lots[_id];
        // On vérifie que le grossiste l'a bien envoyé
        require(lot.etat == State.CREE_PAR_GROSSISTE, "Le lot doit etre cree par le grossiste");

        lot.etat = State.VALIDE_PAR_HOPITAL;
        lot.auteurDerniereAction = msg.sender;
        lot.dateAction = block.timestamp;

        emit ValidationHopital(_id, msg.sender);
    }

    // --- ETAPE 3 : Le Pharmacien récupère le lot pour son stock ---
    function mettreEnPharmacie(uint _id) public {
        LotMedicament storage lot = lots[_id];
        // On vérifie que l'hôpital a validé l'entrée
        require(lot.etat == State.VALIDE_PAR_HOPITAL, "Le lot doit etre valide par l'hopital");

        lot.etat = State.EN_STOCK_PHARMACIE;
        lot.auteurDerniereAction = msg.sender;
        lot.dateAction = block.timestamp;

        emit ReceptionPharmacie(_id, msg.sender);
    }

    // --- ETAPE 4 : L'Infirmier administre le médicament ---
    function administrerPatient(uint _id) public {
        LotMedicament storage lot = lots[_id];
        // On vérifie que c'est bien disponible en pharmacie
        require(lot.etat == State.EN_STOCK_PHARMACIE, "Le lot doit etre en pharmacie");

        lot.etat = State.ADMINISTRE;
        lot.auteurDerniereAction = msg.sender;
        lot.dateAction = block.timestamp;

        emit Administration(_id, msg.sender);
    }
}