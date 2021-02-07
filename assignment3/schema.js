const axios = require('axios');
const{
    GraphQLObjectType,
    GraphQLString,
    GraphQLInt,
    GraphQLSchema,
    GraphQLList,
    GraphQLNonNull
} = require('graphql');


//Voter Type
const Applicant = new GraphQLObjectType({
    name:'Applicant_Info',
    fields:() => ({
        id:{type:GraphQLString},
        name:{type:GraphQLString},
        course:{type:GraphQLString},
        specialisation:{type:GraphQLString},
        grade:{type:GraphQLInt}
    })
});

const Registered = new GraphQLObjectType({
    name:'Registered',
    fields:() => ({
        applicantId:{type:GraphQLString},        
        course:{type:GraphQLString},
        supervisor:{type:GraphQLString}
    })
});



//Root Query 
const RootQuery = new GraphQLObjectType({
    name:'RootQueryType',
    fields:{
        applicant:{
            type:Applicant,
            args:{
                id:{type: GraphQLString}
            },
            //Select information on a specific applicant
            resolve(parentValue, args){
               
                return axios.get('http://localhost:3000/Application/'+ args.id)
                    .then(res => res.info);

                                  
            }
        },

        applicants:{
            type: new GraphQLList(Applicant),
            resolve(parentValue, args){
                return axios.get('http://localhost:3000/Application')
                .then(res => res.info);
            }
        },

       
    }
   
});

//Mutations
const mutation = new GraphQLObjectType({
    name: 'Mutation',
    fields:{
        addApplicant:{
            type: Applicant,
            args:{
                id:{type:new GraphQLNonNull(GraphQLString)},
                name:{type: new GraphQLNonNull(GraphQLString)},
                course:{type: new GraphQLNonNull(GraphQLString)},
                specialisation:{type:new GraphQLNonNull(GraphQLString)},
                grade:{type: new GraphQLNonNull(GraphQLInt)},
           
            },
            resolve(parentValue, args){               
                return axios.post('http://localhost:3000/Application', {
                    id: args.id,
                    name: args.name,
                    course: args.course,
                    specialisation: args.specialisation,
                    grade: args.grade
                })
                .then(res => res.info)
            }
        },

        deleteApplicant:{
            type: Applicant,
            args:{
                id:{type: new GraphQLNonNull(GraphQLString)},
                
            },
            resolve(parentValue, args){               
                return axios.delete('http://localhost:3000/Application/'+args.id)
                .then(res => res.info)
            }
        },

        updateApplicant:{
            type: Applicant,
            args:{
                id:{type:new GraphQLNonNull(GraphQLString)},
                name:{type: new GraphQLNonNull(GraphQLString)},
                course:{type: new GraphQLNonNull(GraphQLString)},
                specialisation:{type:new GraphQLNonNull(GraphQLString)},
                grade:{type: new GraphQLNonNull(GraphQLInt)},
            },
            resolve(parentValue, args){               
                return axios.patch('http://localhost:3000/Application/'+args.id, args)
                .then(res => res.info)
            }
        },

        addRegistered:{
            type: Registered,
            args:{                
                applicantId:{type:new GraphQLNonNull(GraphQLString)},        
                course:{type:new GraphQLNonNull(GraphQLString)},
                supervisor:{type:new GraphQLNonNull(GraphQLString)},
            },
            resolve(parentValue, args){               
                return axios.post('http://localhost:3000/Application', {
                    applicantId: args.applicantId,
                    course: args.course,
                    supervisor: args.supervisor
                })
                .then(res => res.info)
            }
        },
        
        deleteRegistered:{
            type: Registered,
            args:{
                applicantId:{type:new GraphQLNonNull(GraphQLString)}, 
               
            },
            resolve(parentValue, args){               
                return axios.delete('http://localhost:3000/Application/'+args.applicantId)
                .then(res => res.info)
            }
            
        },


       updateCandidate:{
            type: Registered,
            args:{
                applicantId:{type:new GraphQLNonNull(GraphQLString)},        
                course:{type:GraphQLString},
                supervisor:{type:GraphQLString}                
            },

            resolve(parentValue, args){               
                return axios.patch('http://localhost:3000/Application/'+args.applicantId, args)
                .then(res => res.info)
            }

    },
        

    }
})
module.exports = new GraphQLSchema({
    query:RootQuery,
    mutation
});