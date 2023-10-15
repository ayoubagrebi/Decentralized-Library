// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Library {
    address public owner;

    // Structure représentant un livre
    struct Book {
        string title;
        string author;
        bool isAvailable;
        uint256 pricePerDay; // Prix par jour ajouté pour chaque livre
    }

    // Mapping pour stocker les informations sur chaque livre : ID du livre => Livre
    mapping(uint256 => Book) public books;
    // Mapping pour rechercher l'ID d'un livre par son titre
    mapping(string => uint256) public bookIdByTitle;
    // Compteur du nombre de livres
    uint256 public bookCount;

    // Événements pour notifier les actions sur les livres
    event BookAdded(uint256 indexed bookId, string title, string author, uint256 pricePerDay);
    event BookRemoved(uint256 indexed bookId);
    event BookBorrowed(uint256 indexed bookId, address borrower);
    event BookReturned(uint256 indexed bookId, address borrower);

    // Modificateur pour s'assurer que seuls le propriétaire du contrat peut effectuer certaines actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut effectuer cette action");
        _;
    }

    // Constructeur initialisant l'adresse du propriétaire
    constructor() {
        owner = msg.sender;
    }

    // Fonction pour ajouter un livre à la bibliothèque
    function addBook(string memory _title, string memory _author, uint256 _pricePerDay) public onlyOwner {
        bookCount++;
        books[bookCount] = Book(_title, _author, true, _pricePerDay);
        bookIdByTitle[_title] = bookCount;
        emit BookAdded(bookCount, _title, _author, _pricePerDay);
    }

    // Fonction pour obtenir le prix par jour d'un livre spécifique
    function getPricePerDay(uint256 _bookId) public view returns (uint256) {
        require(_bookId <= bookCount && _bookId > 0, "ID de livre invalide");
        return books[_bookId].pricePerDay;
    }

    // Fonction pour emprunter un livre
    function borrowBook(uint256 _bookId) public {
        require(_bookId <= bookCount && _bookId > 0, "ID de livre invalide");
        require(books[_bookId].isAvailable, "Le livre n'est pas disponible");
        books[_bookId].isAvailable = false;
        emit BookBorrowed(_bookId, msg.sender);
    }

  
}
