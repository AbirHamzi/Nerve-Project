import {Component, OnInit} from '@angular/core';
import {Web3Service} from '../../util/web3.service';
import { MatSnackBar } from '@angular/material';
import { NumberValueAccessor } from '@angular/forms/src/directives';

declare let require: any;
const NerveAbi = require('../../../../build/contracts/game.json');
//const Web3 = require('web3');

@Component({
  selector: 'app-meta-sender',
  templateUrl: './meta-sender.component.html',
  styleUrls: ['./meta-sender.component.css']
})
export class MetaSenderComponent implements OnInit {
  accounts: string[];
  nerveContract: any;
  dares: string[];
  key : number;
  users : any;
  pools : any;
  proofID:any;
  selectedActiveDare : any;
  selectedDare : any;
  Activepools : any;
  model = {
    amount: 0,
    receiver: '',
    balance: 0,
    account: ''
  };
  DareYouModel = {
    PoolID : 0,
    BetAmount: 0,
    DareKey: 0,
    player: ''
  };
  DareMeModel = {
    PoolID : 0,
    BetAmount: 0,
    DareKey: 0,
  };
  JoinDareModel = {
    selectedPool: 0,
    BetAmount: 0,
    DareKey: 0,
    player: ''
  };
  DareInfoModel = {
    NbWatchers: 0,
    TotalAmount: 0,
    player: '',
    Dare : '',
    Proof : ''
  };

  status = '';

  constructor(private web3Service: Web3Service, private matSnackBar: MatSnackBar) {
    console.log('Constructor: ' + web3Service);
  }

  ngOnInit(): void {
    console.log('OnInit: ' + this.web3Service);
    console.log(this);
    this.watchAccount();
    this.web3Service.artifactsToContract(NerveAbi)
      .then((contractAbstraction) => {
        this.nerveContract = contractAbstraction;
        this.nerveContract.deployed().then(deployed => {
          console.log(deployed);
          deployed.transferFund({}, (err, ev) => {
            console.log('Transfer event came in, refreshing balance');
            this.refreshBalance();
            this.getDares();
          });
        });

      });
  }
// Detect connected accounts generated from the mnemonic
  watchAccount() {
    this.web3Service.accountsObservable.subscribe((accounts) => {
      this.accounts = accounts;
      this.model.account = accounts[0];
      this.refreshBalance();
    });
  }
// status supervisor
  setStatus(status) {
    this.matSnackBar.open(status, null, {duration: 3000});
  }
// Set the reciever of sendCoin function
  setReceiver(e) {
    console.log('Setting receiver: ' + e.target.value);
    this.model.receiver = e.target.value;
  }
// setAmount of the sendCOin function
  setAmount(e) {
    console.log('Setting amount: ' + e.target.value);
    this.model.amount = e.target.value;
  }
/// send coins from one address to an other 
  async sendCoin() {
    if (!this.nerveContract) {
      this.setStatus('Contract is not loaded, unable to send transaction');
      return;
    }

    const amount = this.model.amount;
    const receiver = this.model.receiver;

    console.log('Sending coins' + amount + ' to ' + receiver);

    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedContract = await this.nerveContract.deployed();
      const transaction = await deployedContract.send.sendTransaction(receiver,{from: this.model.account});

      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error sending ether; see log.');
    }
  }
// refresh the balance of the connected account
  async refreshBalance() {
    console.log('Refreshing balance');
    
    try {
      const deployedContract = await this.nerveContract.deployed();
      console.log(deployedContract);
      console.log('Account', this.model.account);
      const SenderBalance = await deployedContract.getBalance.call();
      console.log('Found balance: ' + deployedContract);
      this.model.balance = SenderBalance/Math.pow(10,18);
    } catch (e) {
      console.log(e);
      this.setStatus('Error getting balance; see log.');
    }
  }
//set the Bet Amount to play nerve
  setBetAmount(e) {
    console.log('Setting BetAmount: ' + e.target.value);
    this.DareYouModel.BetAmount = e.target.value;
  }
  async getDareKey(_dare:string){
    console.log('Trying to load Dare key !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const key = await deployedContract.getDareKey.call(_dare);  
        this.key = key; 
        this.DareYouModel.DareKey = key; 
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading dares; see log.');
    }
  }
// set the target player of a dare
setPlayer(address:string){
    console.log('Setting PLayer address');
    this.DareYouModel.player = address;
  }
 
  async getDares(){
    console.log('Trying to load Dares !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const dares = await deployedContract.getDares.call();
        this.dares = dares;      
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading dares; see log.');
    }
  }
 // get subscribed users list from the blockchain 
  async getUsers(){
    console.log('Trying to load PLayers !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const users = await deployedContract.getUsers.call();
        this.users = users;      
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading dares; see log.');
    }
  }
// Create a prizepool that represents an active dare
  async DareYou(){
    if (!this.nerveContract) {
      this.setStatus('Contract is not loaded, unable to send transaction');
      return;
    }
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedContract = await this.nerveContract.deployed();
      const transaction = await deployedContract.dareYou.sendTransaction(this.DareYouModel.BetAmount,this.DareYouModel.DareKey,this.DareYouModel.player,{from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!'+transaction);
      } else {
        this.setStatus('Transaction complete!'+transaction);
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error creating Pool; see log.');
    }
  } 
// get the list of active dares
  async getActiveDares(){
   console.log('Trying to load Pools !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const pools = await deployedContract.getPools.call();
        this.pools = pools;      
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading pools; see log.');
    }
  }
  // get the list of active dares
  async getMyActiveDares(){
    console.log('Trying to load Pools !!');
     try {
       const deployedContract = await this.nerveContract.deployed();
         const Activepools = await deployedContract.getMyDares.call();
         this.Activepools = Activepools;      
     } catch (e) {
       console.log(e);
       this.setStatus('Error loading your active pools; see log.');
     }
   }
  // select an active dare to join
  setDareID(PoolID:number){
    this.JoinDareModel.selectedPool = PoolID;
 }
 //set the Bet Amount to play nerve
 setbetAmount(e) {
  console.log('Setting BetAmount: ' + e.target.value);
  this.JoinDareModel.BetAmount = e.target.value;
}
  async joinDare(){
    if (!this.nerveContract) {
      this.setStatus('Contract is not loaded, unable to send transaction');
      return;
    }
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedContract = await this.nerveContract.deployed();
      const transaction = await deployedContract.joinDare.sendTransaction(this.JoinDareModel.selectedPool,this.JoinDareModel.BetAmount,{from: this.model.account});
    
        if (!transaction) {
        this.setStatus('Transaction failed!'+transaction);
      } else {
        this.setStatus('Transaction complete!'+transaction);
        this.getDareInfo();
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error joining Pool; see log.');
    }
  }
  async getDareInfo(){
    console.log('Trying to load INFOs !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const Dare = await deployedContract.getActiveDareName.call(this.selectedDare);
        this.DareInfoModel.Dare = Dare;
        const player = await deployedContract.getActiveDarePlayer.call(this.selectedDare);
        this.DareInfoModel.player = player;    
        const NbWatchers = await deployedContract.getActiveDareNBwatchers.call(this.selectedDare);
        this.DareInfoModel.NbWatchers = NbWatchers; 
        const TotalAmount = await deployedContract.getActiveDareAmount.call(this.selectedDare);
        this.DareInfoModel.TotalAmount = TotalAmount; 
        const proof = await deployedContract.getActiveDareProof.call(this.selectedDare);
        this.DareInfoModel.Proof = proof;   
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading your active pools; see log.');
    }
  }
  setbetamount(e) {
    console.log('Setting BetAmount: ' + e.target.value);
    this.DareMeModel.BetAmount = e.target.value;
  }
  async GetDareKey(_dare:string){
    console.log('Trying to load Dare key !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const key = await deployedContract.getDareKey.call(_dare);  
        this.DareMeModel.DareKey = key; 
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading dares key; see log.');
    }
  }
  async DareMe(){
    if (!this.nerveContract) {
      this.setStatus('Contract is not loaded, unable to send transaction');
      return;
    }
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedContract = await this.nerveContract.deployed();
      const transaction = await deployedContract.dareMe.sendTransaction(this.DareMeModel.BetAmount,this.DareMeModel.DareKey,{from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!'+transaction);
      } else {
        this.setStatus('Transaction complete!'+transaction);
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error creating Pool; see log.');
    }
  }
  
  setProofId(e) {
    console.log('Setting proof is: ' + e.target.value);
    this.proofID = e.target.value;
  }
  SelectedActiveDare(poolId:number){
    this.selectedActiveDare = poolId;
  }
  SelectedDare(poolId:number){
    this.selectedDare = poolId;
  }
  async setProof(){
    if (!this.nerveContract) {
      this.setStatus('Contract is not loaded, unable to send transaction');
      return;
    }
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedContract = await this.nerveContract.deployed();
      const transaction = await deployedContract.setProof.sendTransaction(this.selectedDare,this.proofID,{from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!'+transaction);
      } else {
        this.setStatus('Transaction complete!'+transaction);
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting proof; see log.');
    }
  }
  


 

}
