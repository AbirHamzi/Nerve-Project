import {Component, OnInit} from '@angular/core';
import {Web3Service} from '../../util/web3.service';
import { MatSnackBar } from '@angular/material';

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
  model = {
    amount: 0,
    receiver: '',
    balance: 0,
    account: ''
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
  watchAccount() {
    this.web3Service.accountsObservable.subscribe((accounts) => {
      this.accounts = accounts;
      this.model.account = accounts[0];
      this.refreshBalance();
    });
  }

  setStatus(status) {
    this.matSnackBar.open(status, null, {duration: 3000});
  }

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
  async getDareKey(_dare:string){
    console.log('Trying to load Dare key !!');
    try {
      const deployedContract = await this.nerveContract.deployed();
        const key = await deployedContract.getDareKey.call(_dare);
        this.key = key;      
    } catch (e) {
      console.log(e);
      this.setStatus('Error loading dares; see log.');
    }
  }

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

  setAmount(e) {
    console.log('Setting amount: ' + e.target.value);
    this.model.amount = e.target.value;
  }

  setReceiver(e) {
    console.log('Setting receiver: ' + e.target.value);
    this.model.receiver = e.target.value;
  }

 

}
