import React from 'react'
import { Link } from 'react-router'
import moment from 'moment'

import {Table, TableBody, TableHeader, TableHeaderColumn, TableRow, TableRowColumn}
  from 'material-ui/Table';
import TextField from 'material-ui/TextField';
import Paper from 'material-ui/Paper';

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
            <TableHeaderColumn className='table-row-image'>Pokemon</TableHeaderColumn>
            <TableHeaderColumn>Appeared At</TableHeaderColumn>
            <TableHeaderColumn>Captured By</TableHeaderColumn>
            <TableHeaderColumn>Captured At</TableHeaderColumn>
          </TableRow>
        </TableHeader>
        <TableBody displayRowCheckbox={false}>
          {
            this.props.points.map(function(point) {
              return (
                <TableRow key={point.id}>
                  <TableRowColumn className='table-row-image'>
                    <Link to={'/pokemon-id/' + point.friendly_id} className="router-link--underline--false">
                      <Paper style={style} zDepth={2} circle={true} children={  
                        <img style={img_style} src={'https://s3-eu-west-1.amazonaws.com/calpaterson-pokemon/' + point.friendly_id + '.jpeg'} />} 
                      />
                    </Link>
                  </TableRowColumn>
                  <TableRowColumn>{moment(point.create_date).format('LLLL')}</TableRowColumn>
                  <TableRowColumn>{self.renderUserNameLink(point.user_name)}</TableRowColumn>
                  <TableRowColumn>{ (point.capture_date && moment(point.capture_date).format('LLLL')) || 'Uncaptured'}</TableRowColumn>
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
