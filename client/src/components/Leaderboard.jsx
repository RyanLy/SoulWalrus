import React from 'react'
import { Link } from 'react-router'
import moment from 'moment'

import {Table, TableBody, TableHeader, TableHeaderColumn, TableRow, TableRowColumn}
  from 'material-ui/Table';
import TextField from 'material-ui/TextField';
import Paper from 'material-ui/Paper';

class Leaderboard extends React.Component {

  constructor(props) {
    super(props);
  }
  
  
  renderUserNameLink(user_name) {
    return(
          user_name !== 'Not Claimed'
          ?
          <Link to={'/pokemon-user/' + user_name} className="router-link--underline--false"> {user_name} </Link>
          :
          'Not Claimed'
    )
  }
  
  render() {
    let self = this;
    const style = {
      height: 100,
      width: 100,
      margin: 20,
      textAlign: 'center',
      display: 'inline-block',
    };
    const img_style = {
      height: 100,
      width: 100,
      borderRadius: '50%'
    }
    return (
      <Table>
        <TableHeader
          displaySelectAll={false}
          adjustForCheckbox={false}>
          <TableRow>
            <TableHeaderColumn>User</TableHeaderColumn>
            <TableHeaderColumn>Pokemon caught</TableHeaderColumn>
            <TableHeaderColumn className='hidden-xs'>Rarest Pokemon</TableHeaderColumn>
          </TableRow>
        </TableHeader>
        <TableBody displayRowCheckbox={false}>
          {
            Object.keys(this.props.leaderboard).sort().map(function(key) {
              return (
                <TableRow key={key}>
                  <TableRowColumn>{self.renderUserNameLink(key)}</TableRowColumn>
                  <TableRowColumn>
                    {self.props.leaderboard[key].points}
                  </TableRowColumn>
                  <TableRowColumn className='hidden-xs'>
                    <Link to={'/pokemon-id/' + self.props.leaderboard[key].best_pokemon.friendly_id} className="router-link--underline--false">
                      <Paper style={style} zDepth={2} circle={true} children={  
                        <img style={img_style}
                             src={`https://s3-eu-west-1.amazonaws.com/calpaterson-pokemon/${self.props.leaderboard[key].best_pokemon.friendly_id}.jpeg`} />} 
                      />
                    </Link>
                  </TableRowColumn>
                </TableRow>
              )
            })
          }
        </TableBody>
      </Table>
    )
  }
}

module.exports = Leaderboard
