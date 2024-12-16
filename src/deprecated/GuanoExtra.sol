contract GuanoExtra is GuanoCore {

    function previewWithdraw(uint assets) public view returns (uint) {
        return totalRedeemed / (maxWithdraw(msg.sender) / assets - 1);
    }
}