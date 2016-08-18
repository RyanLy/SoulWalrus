import React from 'react'
import { Link } from 'react-router'
import moment from 'moment'

import {Table, TableBody, TableHeader, TableHeaderColumn, TableRow, TableRowColumn}
  from 'material-ui/Table';
import TextField from 'material-ui/TextField';
import Paper from 'material-ui/Paper';
import PokeImage from './PokeImage.jsx';

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
    
    let result = []
    for(let key in this.props.leaderboard) {
      let obj = this.props.leaderboard[key]
      obj.key = key
      result.push(obj)
    }
    
    result = result.sort(
      function(a, b) {
        return b.poke_value - a.poke_value
      }
    )

    return (
      <Table>
        <TableHeader
          displaySelectAll={false}
          adjustForCheckbox={false}>
          <TableRow>
            <TableHeaderColumn>Users</TableHeaderColumn>
            <TableHeaderColumn>Pokemon caught</TableHeaderColumn>
            <TableHeaderColumn>Poke Value</TableHeaderColumn>
            <TableHeaderColumn className='hidden-xs'>Rarest Pokemon</TableHeaderColumn>
          </TableRow>
        </TableHeader>
        <TableBody displayRowCheckbox={false}>
          {
            result.map(function(obj) {
              return (
                <TableRow key={obj.key}>
                  <TableRowColumn>{self.renderUserNameLink(obj.key)}</TableRowColumn>
                  <TableRowColumn>{obj.points}</TableRowColumn>
                  <TableRowColumn>{obj.poke_value}</TableRowColumn>
                  <TableRowColumn className='hidden-xs'><PokeImage point={obj.best_pokemon} /></TableRowColumn>
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
