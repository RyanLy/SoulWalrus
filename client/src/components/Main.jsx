import React from 'react'
import request from 'superagent'
import Pusher from 'pusher-js';

import RefreshIndicator from 'material-ui/RefreshIndicator';
import {Card, CardTitle, CardActions} from 'material-ui/Card';
import Dialog from 'material-ui/Dialog';
import RaisedButton from 'material-ui/RaisedButton';
import FlatButton from 'material-ui/FlatButton';
import TextField from 'material-ui/TextField';

import Loading from './Loading.jsx';

let pusher = new Pusher(ENVIRONMENT.PUSHER_APP_ID, {
  encrypted: true
});

let channelMotd = pusher.subscribe('motd');

class Main extends React.Component {

  constructor(props) {
    super(props);
    this.state = {motd: false, open: false, textFieldValue: ''};
  }
  
  handleOpen() {
   this.setState({open: true});
  };

  handleClose() {
   this.setState({open: false});
  };

  _handleTextFieldChange(e) {
    this.setState({
      textFieldValue: e.target.value
    });
  }
  
  componentDidMount() {
    request
    .get('/v1/motd')
    .end((err, res) => {
      if (res) {
        this.setState({
          motd: res.body.result.message
        });
      }
    });

    channelMotd.bind('motd_update', (data) => {
      this.setState({
        motd: data.result.message
      });
    });
  }
  
  componentWillUnmount() {
    channelMotd.unbind('motd_update');
  }
  
  renderMotd() {
    return (
      <Card>
        <CardTitle title={this.state.motd} subtitle="Message of the day" />
        <CardActions>
          <RaisedButton label="Edit" onClick={this.handleOpen.bind(this)} />
        </CardActions>
      </Card>
    )
  }
  
  render() {
    const actions = [
      <FlatButton
        label="Cancel"
        primary={true}
        onTouchTap={ () => { this.setState({open: false});} }
      />,
      <FlatButton
        label="Submit"
        primary={true}
        keyboardFocused={true}
        onTouchTap={
          () => {
            request
            .patch('/v1/motd')
            .send({submitted_by: 'web_client', message: this.state.textFieldValue})
            .end((err, res) => {
              if (res) {
                this.setState({
                  motd: res.body.result.message
                });
                this.handleClose();
                this.setState({textFieldValue: ''})
              }
            });
          }
        }
      />,
    ];
    
    let refresh =  {
      display: 'inline-block',
      position: 'relative',
    };
    
    return (
      <div>
        <div className="container">
          {
            this.state.motd === false
            ?
            <Loading />
            :
            <div className="row margin-top-15px">
              <div className="col-md-12">
                {this.renderMotd()}
              </div>
            </div>
           }
           <Dialog
             title="Message of the day"
             actions={actions}
             modal={false}
             open={this.state.open}
             onRequestClose={this.handleClose.bind(this)}
           >
             <TextField
                 hintText="New message of the day"
                 multiLine={true}
                 fullWidth={true}
                 rows={1}
                 rowsMax={10}
                 value={this.state.textFieldValue}
                 onChange={this._handleTextFieldChange.bind(this)}
               />
           </Dialog>
        </div>          
      </div>
    )
  }
}

module.exports = Main
