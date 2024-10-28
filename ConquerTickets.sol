// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ConquerTickets is ERC1155, Ownable {
    error AlreadyCanceled();
    error CanceledEvent();
    error NonAvailableTickets();
    error InsufficientBalance();
    error InsufficientTickets();
    error InvalidEventId();
    error InvalidTicketAmount();

    event EventCreated(uint256 id, string name, uint256 totalSupply, uint256 price);
    event TicketBought(address to, uint256 id, uint256 amount);
    event EventCanceled(uint256 id);

    uint256 private eventId;

    struct Event {
        uint256 id;
        string name;
        uint256 totalSupply;
        uint256 availableTickets;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Event) public events;

    constructor() ERC1155("https://api.example/metadata/{id}.json") {
        eventId = 0;
    }

    function createEvent(string memory name, uint256 totalSupply, uint256 price) external onlyOwner {
        require(bytes(name).length > 0, "Event name cannot be empty");
        require(totalSupply > 0, "Total supply must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        eventId += 1;

        events[eventId] = Event({
            id: eventId,
            name: name,
            totalSupply: totalSupply,
            availableTickets: totalSupply,
            price: price,
            isActive: true
        });

        emit EventCreated(eventId, name, totalSupply, price);
    }

    function cancelEvent(uint256 _eventId) external onlyOwner {
        if (!events[_eventId].isActive) {
            revert AlreadyCanceled();
        }

        events[_eventId].isActive = false;
        emit EventCanceled(_eventId);
    }

    function buyTickets(uint256 id, uint256 amount) external payable {
        Event storage _event = events[id];

        if (!_event.isActive) {
            revert CanceledEvent();
        }

        if (_event.availableTickets < amount || amount == 0) {
            revert NonAvailableTickets();
        }

        uint256 totalCost = _event.price * amount;
        if (msg.value < totalCost) {
            revert InsufficientBalance();
        }

        _mint(msg.sender, id, amount, "");

        uint256 refund = msg.value - totalCost;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        emit TicketBought(msg.sender, id, amount);

        _event.availableTickets -= amount;
    }

    function transferTickets(address to, uint256 id, uint256 amount) external {
        require(to != address(0), "Cannot transfer to the zero address");
        require(amount > 0, "Ticket amount must be greater than zero");
        require(balanceOf(msg.sender, id) >= amount, "Insufficient tickets to transfer");

        safeTransferFrom(msg.sender, to, id, amount, "");
    }

    function transferTicketsBatch(address to, uint256[] memory ids, uint256[] memory amounts) external {
        require(to != address(0), "Cannot transfer to the zero address");
        require(ids.length == amounts.length, "IDs and amounts length mismatch");

        for (uint256 i = 0; i < ids.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than zero");
            require(balanceOf(msg.sender, ids[i]) >= amounts[i], "Insufficient tickets to transfer for given ID");
        }

        safeBatchTransferFrom(msg.sender, to, ids, amounts, "");
    }

    function validateTicket(address to, uint256 id) external view returns (uint256) {
        require(to != address(0), "Address must be non-zero");
        return balanceOf(to, id);
    }

    function refundTickets(uint256 id, uint256 amount) external {
        Event storage _event = events[id];

        if (!_event.isActive) {
            revert CanceledEvent();
        }

        if (balanceOf(msg.sender, id) < amount) {
            revert InsufficientTickets();
        }

        require(amount > 0, "Amount must be greater than zero");

        uint256 refundAmount = _event.price * amount;
        payable(msg.sender).transfer(refundAmount);

        _event.availableTickets += amount;
        _burn(msg.sender, id, amount);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No balance to withdraw");
        payable(owner()).transfer(address(this).balance);
    }
}
