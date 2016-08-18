import React from 'react'
import { Link } from 'react-router'
import moment from 'moment'

import {Table, TableBody, TableHeader, TableHeaderColumn, TableRow, TableRowColumn}
  from 'material-ui/Table';
import TextField from 'material-ui/TextField';
import PokeImage from './PokeImage.jsx';

class PokeTable extends React.Component {

  constructor(props) {
    super(props);
  }
  
  componentDidMount() {
    Notification.requestPermission()
  }
  
  renderUserNameLink(user_name) {
    return(
          user_name
          ?
          <Link to={'/pokemon-user/' + user_name} className="router-link--underline--false"> {user_name} </Link>
          :
          'Uncaptured'
    )
  }
  
  render() {
    return (
      <Table>
        <TableHeader
          displaySelectAll={false}
          adjustForCheckbox={false}>
          <TableRow>
            <TableHeaderColumn className='table-row-image'>Pokemon</TableHeaderColumn>
            <TableHeaderColumn className='hidden-xs'>Appeared At</TableHeaderColumn>
            <TableHeaderColumn>Captured By</TableHeaderColumn>
            <TableHeaderColumn className='hidden-xs'>Captured At</TableHeaderColumn>
          </TableRow>
        </TableHeader>
        <TableBody displayRowCheckbox={false}>
          {
            this.props.points.map((point) => {
              return (
                <TableRow key={point.id}>
                  <TableRowColumn className='table-row-image'><PokeImage point={point} /></TableRowColumn>
                  <TableRowColumn className='hidden-xs'>{moment(point.create_date).format('LLLL')}</TableRowColumn>
                  <TableRowColumn>{this.renderUserNameLink(point.user_name)}</TableRowColumn>
                  <TableRowColumn className='hidden-xs'>{ (point.capture_date && moment(point.capture_date).format('LLLL')) || 'Uncaptured'}</TableRowColumn>
                </TableRow>
              )
            })
          }
        </TableBody>
      </Table>
    )
  }
}

module.exports = PokeTable
