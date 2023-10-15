// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Library.sol";

contract LoanManager {
    address public owner;
    Library public libraryContract;

    // Mapping pour stocker les détails des emprunts : emprunteur => ID du livre => détails de l'emprunt (horodatage, prix, etc.)
    mapping(address => mapping(uint256 => uint256)) public loanDetails;
    // Mapping pour suivre les livres empruntés : emprunteur => ID du livre => horodatage de l'emprunt
    mapping(address => mapping(uint256 => uint256)) public borrowedBooks;
    // Mapping pour compter le nombre de livres empruntés par emprunteur
    mapping(address => uint256) public borrowedBookCount;

    // Événements pour notifier les actions sur les emprunts
    event LoanRequested(address indexed borrower, uint256 indexed bookId);
    event LoanApproved(address indexed borrower, uint256 indexed bookId, uint256 loanPeriod, uint256 totalPrice);
    event LoanReturned(address indexed borrower, uint256 indexed bookId);

    // Constructeur initialisant l'adresse du propriétaire et le contrat de la bibliothèque
    constructor(address _libraryAddress) {
        owner = msg.sender;
        libraryContract = Library(_libraryAddress);
    }

    // Modificateur pour s'assurer que seuls le propriétaire du contrat peut effectuer certaines actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut effectuer cette action");
        _;
    }

    // Fonction pour approuver un emprunt pour un emprunteur et un livre spécifiques
    function approveLoan(address _borrower, uint256 _bookId, uint256 _loanPeriodInDays, uint256 _pricePerDay) public onlyOwner {
        libraryContract.borrowBook(_bookId);

        // Calcul du coût total de la location
        uint256 totalPrice = _loanPeriodInDays * _pricePerDay;

        // Vérification si l'emprunteur a suffisamment de fonds
        require(getAccountBalance(_borrower) >= totalPrice, "Fonds insuffisants sur le compte de l'emprunteur");

        // Enregistrement des détails de l'emprunt
        loanDetails[_borrower][_bookId] = block.timestamp + _loanPeriodInDays * 1 days;

        emit LoanApproved(_borrower, _bookId, _loanPeriodInDays, totalPrice);

        // Incrémentation du nombre de livres empruntés
        borrowedBookCount[_borrower]++;
    }

    // Fonction pour retourner un livre emprunté
    function returnLoan(uint256 _bookId) public {
        (string memory title, string memory author, bool isAvailable, ) = libraryContract.books(_bookId);
        require(!isAvailable, "Le livre est deja disponible");

        uint256 returnDate = loanDetails[msg.sender][_bookId];
        require(returnDate > 0 && block.timestamp >= returnDate, "Periode d'emprunt non terminee");

        //libraryContract.returnBook(_bookId);
        delete loanDetails[msg.sender][_bookId];
        emit LoanReturned(msg.sender, _bookId);

        // Décrémentation du nombre de livres empruntés
        borrowedBookCount[msg.sender]--;
    }

    // Fonction pour obtenir le nombre de livres actuellement empruntés par un emprunteur
    function getBorrowedBookCount(address _borrower) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= libraryContract.bookCount(); i++) {
            if (loanDetails[_borrower][i] > 0) {
                count++;
            }
        }
        return count;
    }

    // Fonction pour demander l'emprunt d'un livre pour une période de prêt spécifiée
    function requestLoan(uint256 _bookId, uint256 _loanPeriodInDays) public {
        (string memory title, string memory author, bool isAvailable, ) = libraryContract.books(_bookId);

        require(_loanPeriodInDays >= 1 && _loanPeriodInDays <= 45, "La periode d'emprunt doit etre comprise entre 1 et 45 jours");
        if (!isAvailable) {
            revert("Le livre n'est pas disponible");
        }

        require(getBorrowedBookCount(msg.sender) < 3, "Vous ne pouvez pas emprunter plus de 3 livres");

        uint256 pricePerDay = libraryContract.getPricePerDay(_bookId);
        uint256 totalPrice = _loanPeriodInDays * pricePerDay;

        // Ajout de l'ID du livre directement dans le tableau
        borrowedBooks[msg.sender][_bookId] = block.timestamp + _loanPeriodInDays * 1 days;

        emit LoanRequested(msg.sender, _bookId);
    }

    // Fonction pour obtenir le solde disponible du compte d'un emprunteur après déduction du montant emprunté
    function getAccountBalance(address _borrower) public view returns (uint256) {
        // Obtenir le solde du compte
        uint256 accountBalance = payable(_borrower).balance;

        // Soustraire le montant emprunté pour le compte appelant
        uint256 borrowedAmount = 0;

        for (uint256 i = 1; i <= libraryContract.bookCount(); i++) {
            if (loanDetails[_borrower][i] > 0) {
                // Calcul du coût total de la location
                uint256 loanPeriodInDays = (loanDetails[_borrower][i] - block.timestamp) / 1 days;
                uint256 pricePerDay = libraryContract.getPricePerDay(i);
                borrowedAmount += loanPeriodInDays * pricePerDay;
            }
        }

        // S'assurer que le montant emprunté n'excède pas le solde du compte
        if (borrowedAmount >= accountBalance) {
            return 0; // Renvoyer 0 si le montant emprunté dépasse le solde du compte
        }

        // Renvoyer le solde disponible pour le compte appelant
        return accountBalance - borrowedAmount;
    }
}
