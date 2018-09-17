
pragma solidity ^0.4.25;

/*
 * The actual smart contract that can store a message, an image and tags for each user
 */
contract ImgStorage
{
    address[10] accounts = [0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1, 
                            0xffcf8fdee72ac11b5c542428b35eef5769c409f0,
                            0x22d491bde2303f2f43325b2108d26f1eaba1e32b,
                            0xe11ba2b4d45eaed5996cd0823791e0c93114882d,
                            0xd03ea8624c8c5987235048901fb614fdca89b117,
                            0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc,
                            0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9,
                            0x28a8746e75304c0780e011bed21c72cd78cd535e,
                            0xaca94ef8bd5ffee41947b4585a84bda5a3d3da6e,
                            0x1df62f291b2e969fb0849d99d9ce41e2f137006e];
	// data structure to contain message, image and tags
	struct UserState
	{
        string userMessage;
        //bytes userImage;
        string userTags;
	}
	
	// create a mapping from account-address to UserState,
	// this way, each user can store his own state,
	// the history is within the blockchain and can be retrieved as well
	// --> nothing lost
	mapping (address => UserState) userMapping;

	// now just some functions to actually set a new state and request it
	function getOwnUserState() constant returns(string, string)
	{
	    return getUserState(msg.sender);
	}

	function getUserState(address target) constant returns(string, string)
	{
        return (userMapping[target].userMessage,
                //userMapping[target].userImage,
                userMapping[target].userTags);
	}

	function setNewUserState(string message, string tags)
	{
		userMapping[msg.sender].userMessage = message;
		//userMapping[msg.sender].userImage = imgData;
		userMapping[msg.sender].userTags = tags;
	}
	
	struct Review{
	    string content;
	    address reviewer;
	}

	struct Essay
	{
	address author;
	string title;
	bytes content;
	string topics;
	Review[2] review;
	}

	mapping (address => Essay) userEssay;	

	function uploadEssay(bytes content, string topics,string title)
	{
		userEssay[msg.sender].content = content;
		userEssay[msg.sender].title = title;
		userEssay[msg.sender].author = msg.sender;
		userEssay[msg.sender].topics = topics;
		uint seed = block.difficulty;
		while (true){
		    uint first = random(seed);
		    seed++;
		    if (accounts[first] != msg.sender){
		        uint second = random(seed);
		        seed++;
		        if (accounts[second] != msg.sender && accounts[first] != accounts[second])
		        break;
		    }
		}
		userEssay[msg.sender].review[0].reviewer = 0xffcf8fdee72ac11b5c542428b35eef5769c409f0;//accounts[first];
		userEssay[msg.sender].review[1].reviewer = 0x22d491bde2303f2f43325b2108d26f1eaba1e32b;//accounts[second];
	}

	function uploadReview(string title, string review)
	{
	    for (uint i = 0;i <= 9;i++){
	        if (strcmp(userEssay[accounts[i]].title,title)){
	            address r1 = userEssay[accounts[i]].review[0].reviewer;
	            address r2 = userEssay[accounts[i]].review[1].reviewer;
	            break;
	        }
	    }
		require(msg.sender == r1 || msg.sender == r2,
		"sorry, you don't have permission to review this essay");
		require(!strcmp(userEssay[accounts[i]].review[0].content,'') || !strcmp(userEssay[accounts[i]].review[1].content,''),
		"this essay has already been reviewed");
		if (r1 == msg.sender) userEssay[accounts[i]].review[0].content = review;
		else userEssay[accounts[i]].review[1].content = review;
	}
	
	//利用哈希函数实现随机数
	function random(uint seed) private returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, seed))%10);
    }
    
    //利用哈希函数实现字符串比较
    function strcmp(string a, string b) returns (bool){
        return keccak256(a) == keccak256(b);
    }
}
