import csv
import itertools
import sys
import numpy as np

PROBS = {

    # Unconditional probabilities for having gene
    "gene": { 
        2: 0.01,
        1: 0.03,
        0: 0.96
    },

    "trait": {

        # Probability of trait given two copies of gene
        2: { 
            True: 0.65,
            False: 0.35
        },

        # Probability of trait given one copy of gene
        1: {
            True: 0.56,
            False: 0.44
        },

        # Probability of trait given no gene
        0: {
            True: 0.01,
            False: 0.99
        }
    },

    # Mutation probability
    "mutation": 0.01
}


def main():

    # Check for proper usage
    if len(sys.argv) != 2:
        sys.exit("Usage: python heredity.py data.csv")
    people = load_data(sys.argv[1])

    # Keep track of gene and trait probabilities for each person
    probabilities = {
        person: {
            "gene": {
                2: 0,
                1: 0,
                0: 0
            },
            "trait": {
                True: 0,
                False: 0
            }
        }
        for person in people
    }

    # Loop over all sets of people who might have the trait
    names = set(people)
    for have_trait in powerset(names):

        # Check if current set of people violates known information
        fails_evidence = any(
            (people[person]["trait"] is not None and
             people[person]["trait"] != (person in have_trait))
            for person in names
        )
        if fails_evidence:
            continue

        # Loop over all sets of people who might have the gene
        for one_gene in powerset(names):
            for two_genes in powerset(names - one_gene):

                # Update probabilities with new joint probability
                p = joint_probability(people, one_gene, two_genes, have_trait)
                update(probabilities, one_gene, two_genes, have_trait, p)

    # Ensure probabilities sum to 1
    normalize(probabilities)

    # Print results
    for person in people:
        print(f"{person}:")
        for field in probabilities[person]:
            print(f"  {field.capitalize()}:")
            for value in probabilities[person][field]:
                p = probabilities[person][field][value]
                print(f"    {value}: {p:.4f}")


def load_data(filename):
    """
    Load gene and trait data from a file into a dictionary.
    File assumed to be a CSV containing fields name, mother, father, trait.
    mother, father must both be blank, or both be valid names in the CSV.
    trait should be 0 or 1 if trait is known, blank otherwise.
    """
    data = dict()
    with open(filename) as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row["name"]
            data[name] = {
                "name": name,
                "mother": row["mother"] or None,
                "father": row["father"] or None,
                "trait": (True if row["trait"] == "1" else
                          False if row["trait"] == "0" else None)
            }
    return data


def powerset(s):
    """
    Return a list of all possible subsets of set s.
    """
    s = list(s)
    return [
        set(s) for s in itertools.chain.from_iterable(
            itertools.combinations(s, r) for r in range(len(s) + 1)
        )
    ]

def how_many_genes_and_having_trait(person,one_gene,two_genes,have_trait):
    #genes = []
    #trait = []

    #how many genes person has
    if (person in one_gene):
        genes = 1
    elif(person in two_genes):
        genes = 2
    else:
        genes = 0

    #does person have trait or not
    if (person in have_trait):
        trait = True
    else:
        trait = False

    return int(genes),trait

def get_gene_pass_probs(genes):

    if(genes == 0):
        gene_pass = PROBS["mutation"]
        not_gene_pass = 1-PROBS["mutation"]
    elif(genes == 1):
        gene_pass = 0.5
        not_gene_pass = 0.5
    else:
        # genes == 2
        gene_pass = 1 - PROBS["mutation"]
        not_gene_pass = PROBS["mutation"]
    return gene_pass,not_gene_pass

def prob_of_passing_trait_to_child(genes, trait,people,person,one_gene,two_genes,have_trait):


    genes_father,trait_father = how_many_genes_and_having_trait(people[person]["father"],one_gene,two_genes,have_trait)
    genes_mother,trait_mother = how_many_genes_and_having_trait(people[person]["mother"],one_gene,two_genes,have_trait)

    gene_from_father,not_gene_from_father = get_gene_pass_probs(genes_father)
    gene_from_mother,not_gene_from_mother = get_gene_pass_probs(genes_mother)



    #gene_from_father = PROBS["mutation"]
    #gene_from_mother = PROBS["mutation"]

    #not_gene_from_father = 1-PROBS["mutation"]
    #not_gene_from_mother = 1 - PROBS["mutation"]


    #if(father_trait):
    #    gene_from_father = 1-PROBS["mutation"]
    #    not_gene_from_father = PROBS["mutation"]

    #if(mother_trait):
    #    gene_from_mother = 1-PROBS["mutation"]
    #    not_gene_from_mother = PROBS["mutation"]


    #print("gene_from_father: ",gene_from_father)
    #print("gene_from_mother: ",gene_from_mother)
    #print("not_gene_from_father: ",not_gene_from_father)
    #print("not_gene_from_mother: ",not_gene_from_mother)

    if(genes == 0):
        #both parents don't pass gene
        prob = not_gene_from_father*not_gene_from_mother
        trait_prob = prob*PROBS["trait"][genes][trait]
        #print("genes + trait_prob + trait : ", genes, " ", trait_prob," ",trait)
        return trait_prob
    elif(genes == 1):
        #only one parent pass gene and another doesn't pass gene
        prob = gene_from_father*not_gene_from_mother + not_gene_from_father*gene_from_mother
        trait_prob = prob * PROBS["trait"][genes][trait]
        #print("genes + trait_prob + trait : ", genes, " ", trait_prob," ",trait)
        return trait_prob
    else:
        #genes == 2
        #both parents pass gene
        prob = gene_from_father*gene_from_mother
        trait_prob = prob * PROBS["trait"][genes][trait]
        #print("genes + trait_prob + trait : ", genes, " ", trait_prob," ",trait)
        return trait_prob


def joint_probability(people, one_gene, two_genes, have_trait):
    """
    Compute and return a joint probability.

    The probability returned should be the probability that
        * everyone in set `one_gene` has one copy of the gene, and
        * everyone in set `two_genes` has two copies of the gene, and
        * everyone not in `one_gene` or `two_gene` does not have the gene, and
        * everyone in set `have_trait` has the trait, and
        * everyone not in set` have_trait` does not have the trait.
    """

    joint_probs = []

    for person in people:
        #person_prob = 0


        #No parents
        if (people[person]["mother"] == None and people[person]["father"] == None):
            genes,trait = how_many_genes_and_having_trait(person,one_gene,two_genes,have_trait)
            person_prob = PROBS["gene"][genes]*PROBS["trait"][genes][trait]
        else:
            #this is case where person has parents and inherits genes
            genes, trait = how_many_genes_and_having_trait(person, one_gene, two_genes, have_trait)

            #person_father = people[person]["father"]
            #father_trait = people[person_father]["trait"]

            #person_mother = people[person]["mother"]
            #mother_trait = people[person_mother]["trait"]

            person_prob = prob_of_passing_trait_to_child(genes, trait,people,person,one_gene,two_genes,have_trait)



        joint_probs.append(person_prob)
    return np.prod(joint_probs)


def update(probabilities, one_gene, two_genes, have_trait, p):
    """
    Add to `probabilities` a new joint probability `p`.
    Each person should have their "gene" and "trait" distributions updated.
    Which value for each distribution is updated depends on whether
    the person is in `have_gene` and `have_trait`, respectively.
    """
    for person in probabilities:
        genes,trait = how_many_genes_and_having_trait(person, one_gene, two_genes, have_trait)
        probabilities[person]["gene"][genes] += p
        probabilities[person]["trait"][trait] += p



def normalize(probabilities):
    """
    Update `probabilities` such that each probability distribution
    is normalized (i.e., sums to 1, with relative proportions the same).
    """
    for person in probabilities:
        gene_probs = probabilities[person]["gene"][0] + probabilities[person]["gene"][1] + probabilities[person]["gene"][2]

        #normalize gene probs
        probabilities[person]["gene"][0] = probabilities[person]["gene"][0]/gene_probs
        probabilities[person]["gene"][1] = probabilities[person]["gene"][1] / gene_probs
        probabilities[person]["gene"][2] = probabilities[person]["gene"][2] / gene_probs

        trait_probs = probabilities[person]["trait"][False] + probabilities[person]["trait"][True]

        #normalize trait probs
        probabilities[person]["trait"][False] = probabilities[person]["trait"][False] / trait_probs
        probabilities[person]["trait"][True] = probabilities[person]["trait"][True] / trait_probs




if __name__ == "__main__":
    main()
