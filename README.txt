# Contrats de Bibliothèque Décentralisée

Ce référentiel contient deux contrats intelligents Ethereum pour un système de bibliothèque décentralisée : `Library.sol` et `LoanManager.sol`. Ces contrats sont conçus pour gérer l'inventaire des livres d'une bibliothèque et gérer les opérations de prêt et de retour de livres.

## Library.sol

### Aperçu
Le contrat `Library` représente une bibliothèque décentralisée et inclut des fonctionnalités pour ajouter des livres, vérifier la disponibilité des livres et emprunter des livres.

### Fonctions
- `addBook`: Ajouter un nouveau livre à la bibliothèque.
- `getPricePerDay`: Obtenir le prix par jour pour un livre spécifique.
- `borrowBook`: Emprunter un livre de la bibliothèque.

### Événements
- `BookAdded`: Déclenché lorsqu'un nouveau livre est ajouté à la bibliothèque.
- `BookBorrowed`: Déclenché lorsqu'un livre est emprunté.

## LoanManager.sol

### Aperçu
Le contrat `LoanManager` gère les opérations de prêt et de retour de livres, y compris l'approbation par le propriétaire de la bibliothèque et le suivi des détails des emprunts.

### Fonctions
- `approveLoan`: Approuver une demande de prêt pour un emprunteur et un livre spécifiques.
- `returnLoan`: Retourner un livre emprunté à la bibliothèque.
- `getBorrowedBookCount`: Obtenir le nombre de livres actuellement empruntés par un emprunteur.
- `requestLoan`: Demander l'emprunt d'un livre pour une période de prêt spécifiée.

### Événements
- `LoanRequested`: Déclenché lorsqu'un emprunteur demande à emprunter un livre.
- `LoanApproved`: Déclenché lorsqu'un prêt est approuvé par le propriétaire de la bibliothèque.
- `LoanReturned`: Déclenché lorsqu'un livre emprunté est retourné.

## Utilisation

Pour déployer ces contrats, vous pouvez utiliser des outils de développement Ethereum tels que Remix. Assurez-vous de déployer le contrat `Library` avant de déployer le contrat `LoanManager`, car ce dernier dépend du premier.